# frozen_string_literal: true

require "concurrent/actor"
require "forwardable"

require_relative "packets"

module Moleculer
  ##
  # Transit class
  class Transit
    extend Forwardable
    ##
    # The transit handler simply handles the processing of incoming messages asynchronously
    class Handler < Concurrent::Actor::RestartingContext
      def initialize(transit)
        @transit = transit
      end

      def on_message(message)
        if message.payload[:ver] != Moleculer::PROTOCOL_VERSION
          raise(
            Errors::ProtocolMismatchError,
            node_id:  message.payload[:sender],
            actual:   Moleculer::PROTOCOL_VERSION,
            received: message.payload[:ver],
          )
        end

        if message.payload[:sender] == @transit.broker.node_id &&
           ![Packets::EVENT, Packets::REQ, Packets::RES].include?(message.class)
          return
        end

        @transit.logger.debug("Incoming '#{message.type}' packet from '#{message.payload[:sender]}")
        case message
        when Packets::DISCOVER
          @transit.send_node_info(message.payload[:sender])
        when Packets::INFO
          @transit.process_node_info(message)
        when Packets::HEARTBEAT
          @transit.process_heartbeat(message)
        when Packets::RES
          @transit.process_response(message)
        when Packets::REQ
          @transit.process_request(message)
        end
      end
    end

    def_delegators :@broker, :registry, :serializer, :node_id, :transporter

    attr_reader :broker, :handler, :logger

    def initialize(broker, options)
      @broker            = broker
      @options           = options
      @logger            = @broker.get_logger("transit")
      @connected         = false
      @disconnecting     = false
      @is_ready          = true
      @disable_reconnect = @options[:disable_reconnect]
      @handler           = Handler.spawn(:handler, self)
    end

    def connect
      @logger.info("Connecting to the transporter...")
      t            = transporter.new(self, @broker.options[:transporter], subscriptions)
      @transporter = t # prevents @transporter from being assigned when an exception happens
      send_node_info
      send_discover
      # rescue StandardError => e
      #   @logger.warn("Connection is failed. #{e.message}")
      #   @logger.debug(e)
      #   return if @disable_reconnect

      # retry
    end

    def disconnect
      @logger.info "Disconnecting from the transporter..."
      send_disconnect
      @transporter.disconnect
    end

    def subscriptions
      [
        { type: Packets::DISCONNECT, node_id: node_id },
        { type: Packets::DISCOVER },
        { type: Packets::DISCOVER, node_id: node_id },
        { type: Packets::EVENT, node_id: node_id },
        { type: Packets::HEARTBEAT },
        { type: Packets::INFO, node_id: node_id },
        { type: Packets::REQ, node_id: node_id },
        { type: Packets::RES, nod_id: node_id },
        { type: Packets::INFO },
        { type: Packets::PING },
        { type: Packets::PING, node_id: node_id },
        { type: Packets::PONG, node_id: node_id },
      ]
    end

    def send_node_info(sender = nil)
      publish(Packets::INFO.new(registry.local_node.schema), sender)
    end

    def send_discover(sender = nil)
      publish(Packets::DISCOVER.new, sender)
    end

    def send_heartbeat
      publish(Packets::HEARTBEAT.new, nil)
    end

    def send_event(name, payload, groups, broadcast, node_id)
      publish(Packets::EVENT.new(
                event:     name,
                data:      payload,
                groups:    groups.empty? ? nil : groups,
                broadcast: broadcast,
              ), node_id)
    end

    def send_action(action, context)
      publish(Packets::REQ.new(
                action:    action.name,
                node_id:   action.node_id,
                params:    context.params,
                meta:      context.meta,
                timeout:   context.options[:timeout] || 0,
                level:     context.level,
                metrics:   context.meta,
                parent_id: context.parent_id,
                id:        context.request_id,
              ), action.node_id)
    end

    def send_response(response)
      publish(Packets::RES.new(
                id:      response[:id],
                success: response[:success],
                data:    response[:data],
              ), response[:sender])
    end

    def send_disconnect
      publish(Packets::DISCONNECT.new, nil)
    end

    def process_node_info(packet)
      registry.process_node_info(packet)
    end

    def process_heartbeat(packet)
      registry.process_heartbeat(packet)
    end

    def process_response(packet)
      @broker.add_response(packet.payload[:id], packet.payload)
    end

    def process_request(packet)
      payload  = packet.payload
      response = @broker.call(payload[:action], payload[:params],
                              meta:       payload[:meta],
                              level:      payload[:level],
                              timeout:    payload[:timeout],
                              metrics:    payload[:metrics],
                              request_id: payload[:id])
      send_response(
        id:      payload[:id],
        success: true,
        data:    response,
      )
    end

    def publish(packet, sender)
      @logger.debug("Send '#{packet.type}' packet to '#{sender || '<all nodes>'}'")
      @transporter.publish(packet, sender)
    end
  end
end
