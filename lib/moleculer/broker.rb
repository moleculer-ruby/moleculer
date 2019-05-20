# frozen_string_literal: true

require "forwardable"

require_relative "registry"
require_relative "transporters"
require_relative "support"

module Moleculer
  ##
  # The Broker is the primary component of Moleculer. It handles action, events, and communication with remote nodes.
  # Only a single broker should be run for any given process, and it is automatically started when Moleculer::start or
  # Moleculer::run is called.
  class Broker
    include Moleculer::Support
    extend Forwardable
    attr_reader :config

    def_delegators :@config, :node_id, :heartbeat_interval, :services, :service_prefix

    ##
    # @param config [Moleculer::Config] the broker configuration
    def initialize(config)
      @config = config

      @config.broker = self

      @logger      = @config.logger.get_child("[BROKER]")
      @registry    = Registry.new(@config)
      @transporter = Transporters.for(@config.transporter).new(@config)
      @contexts    = Concurrent::Map.new
    end

    ##
    # Call the provided action.
    #
    # @param action_name [String] the action to call.
    # @param params [Hash] the params with which to call the action
    # @param meta [Hash] the metadata of the request
    #
    # @return [Hash] the return result of the action call
    def call(action_name, params, meta: {}, node_id: nil, timeout: Moleculer.config.timeout)
      action = node_id ? @registry.fetch_action_for_node_id(action_name, node_id) : @registry.fetch_action(action_name)

      context = Context.new(
        broker:  self,
        action:  action,
        params:  params,
        meta:    meta,
        timeout: timeout,
      )

      future = Concurrent::Promises.resolvable_future

      @contexts[context.id] = {
        context:   context,
        called_at: Time.now,
        future:    future,
      }

      action.execute(context, self)

      future.value!(context.timeout)
    end

    def emit(event_name, payload)
      @logger.debug("emitting event '#{event_name}'")
      events = @registry.fetch_events_for_emit(event_name)

      events.each { |e| e.execute(payload, self) }
    end

    ##
    # Runs the broker in the foreground.
    def run
      self_read, self_write = IO.pipe

      %w[INT TERM].each do |sig|
        trap sig do
          self_write.puts(sig)
        end
      end

      begin
        start

        while (readable_io = IO.select([self_read]))
          signal           = readable_io.first[0].gets.strip
          handle_signal(signal)
        end
      rescue Interrupt
        stop
      end
    end

    ##
    # Starts the broker. This will start the broker in the background, to run it in the foreground use #run
    def start
      @logger.info "starting"
      @transporter.start
      register_local_node
      start_subscribers
      publish_discover
      publish_info
      start_heartbeat
      @started = true
      self
    end

    ##
    # @return [Boolean] whether or not the broker is started
    def started?
      @started || false
    end

    ##
    # Stops the broker.
    def stop
      @logger.info "stopping"
      publish(:disconnect)
      @transporter.stop
    end

    def wait_for_services(*services)
      until (services = @registry.missing_services(*services)) && services.empty?
        @logger.info "waiting for services '#{services.join(', ')}'"
        sleep 0.1
      end
    end

    def local_node
      @registry.local_node
    end

    ##
    # Processes an incoming message and passes it to the appropriate channel for handling
    #
    # @param [String] channel the channel in which the message came in on
    # @param [Hash] message the raw deserialized message
    def process_message(channel, message)
      subscribers[channel] << Packets.for(channel.split(".")[1]).new(message) if subscribers[channel]
    rescue StandardError => e
      @logger.error e
    end

    def process_response(packet)
      context = @contexts.delete(packet.id)
      context[:future].fulfill(packet.data)
    end

    def process_event(packet)
      @logger.debug("processing event '#{packet.event}'")
      events = @registry.fetch_events_for_emit(packet.event)

      events.each { |e| e.execute(packet.data, self) }
    rescue StandardError => e
      @logger.error e
    end

    def process_request(packet)
      @logger.debug "processing request #{packet.id}"
      action = @registry.fetch_action_for_node_id(packet.action, node_id)
      node   = @registry.fetch_node(packet.sender)

      context = Context.new(
        id:      packet.id,
        broker:  self,
        action:  action,
        params:  packet.params,
        meta:    packet.meta,
        timeout: @config.timeout,
      )

      response = action.execute(context, self)

      publish_res(
        id:      context.id,
        success: true,
        data:    response,
        error:   {},
        meta:    context.meta,
        stream:  false,
        node:    node,
      )
    end

    ##
    # @return [Proc] returns the rescue_action if defined on the configuration
    def rescue_action
      config.rescue_action
    end

    ##
    # @return [Proc] returns the rescue_event if defined on the configuration
    def rescue_event
      config.rescue_event
    end

    private

    def handle_signal(sig)
      case sig
      when "INT", "TERM"
        raise Interrupt
      end
    end

    def publish(packet_type, message = {})
      packet = Packets.for(packet_type).new(message.merge(sender: @registry.local_node.id))
      @transporter.publish(packet)
    end

    def publish_event(event_data)
      publish_to_node(:event, event_data.delete(:node), event_data)
    end

    def publish_heartbeat
      publish(:heartbeat)
    end

    ##
    # Publishes the discover packet
    def publish_discover
      publish(:discover)
    end

    def publish_info(node_id = nil)
      return publish(:info, @registry.local_node.as_json) unless node_id

      node = @registry.safe_fetch_node(node_id) || node_id
      publish_to_node(:info, node, @registry.local_node.as_json)
    end

    def publish_req(request_data)
      publish_to_node(:req, request_data.delete(:node), request_data)
    end

    def publish_res(response_data)
      publish_to_node(:res, response_data.delete(:node), response_data)
    end

    def publish_to_node(packet_type, node, message = {})
      packet = Packets.for(packet_type).new(message.merge(node: node))
      @transporter.publish(packet)
    end

    def register_local_node
      @logger.info "registering #{services.length} local services"
      services.each { |s| s.broker = self }
      node                         = Node.new(
        node_id:  node_id,
        services: services,
        local:    true,
      )
      @registry.register_node(node)
    end

    def register_or_update_remote_node(info_packet)
      node = Node.from_remote_info(info_packet)
      @registry.register_node(node)
    end

    def register_local_services
      services.each do |service|
        register_service(service)
      end
    end

    def register_service(service)
      @registry.register_local_service(service)
    end

    def start_heartbeat
      @heartbeat = Concurrent::TimerTask.new(execution_interval: heartbeat_interval) do
        publish_heartbeat
        @registry.expire_nodes
      end.execute
    end

    def start_subscribers
      subscribe_to_info
      subscribe_to_res
      subscribe_to_req
      subscribe_to_events
      subscribe_to_discover
      subscribe_to_disconnect
      subscribe_to_heartbeat
    end

    def subscribe_to_events
      subscribe("MOL.EVENT.#{node_id}") do |packet|
        process_event(packet)
      end
    end

    def subscribe_to_info
      subscribe("MOL.INFO.#{node_id}") do |packet|
        register_or_update_remote_node(packet)
      end
      subscribe("MOL.INFO") do |packet|
        register_or_update_remote_node(packet)
      end
    end

    def subscribe_to_res
      subscribe("MOL.RES.#{node_id}") do |packet|
        process_response(packet)
      end
    end

    def subscribe_to_req
      subscribe("MOL.REQ.#{node_id}") do |packet|
        process_request(packet)
      end
    end

    def subscribe_to_discover
      subscribe("MOL.DISCOVER") do |packet|
        publish_info(packet.sender) unless packet.sender == node_id
      end
      subscribe("MOL.DISCOVER.#{node_id}") do |packet|
        publish_info(packet.sender)
      end
    end

    def subscribe_to_heartbeat
      subscribe("MOL.HEARTBEAT") do |packet|
        node = @registry.safe_fetch_node(packet.sender)
        node.beat
      end
    end

    def subscribe_to_disconnect
      subscribe("MOL.DISCONNECT") do |packet|
        @registry.remove_node(packet.sender)
      end
    end

    def subscribe(channel, &block)
      @transporter.subscribe(channel, &block)
    end
  end
end
