# frozen_string_literal: true

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

    ##
    # @private
    # A queue is a subscriber thread pool manager allowing Moleculer to handle requests asynchronously
    class Queue
      def initialize(name, options, &block)
        opts      = { max_threads: 1, min_threads: 1, max_queue: 0, fallback_policy: :abort }.merge(options)
        @executor = block
        # noinspection RubyArgCount
        @pool   = Concurrent::ThreadPoolExecutor.new(opts)
        @name   = name
        @logger = Moleculer.logger
      end

      ##
      # Pushes a packet onto the queue by queuing the action in the thread pool
      #
      # @param [Moleculer::Packet::Base] packet the packet to queue into the pool
      def <<(packet)
        @pool.post do
          begin
            @executor.call(packet)
          rescue StandardError => e
            @logger.error e
          end
        end
      end
    end

    attr_reader :logger

    def initialize
      @registry    = Registry.new(self)
      @logger      = Moleculer.logger
      @transporter = Transporters.for(Moleculer.transporter, self)
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
    def call(action_name, params, meta: {}, node_id: nil, timeout: Moleculer.timeout) # rubocop:disable Metrics/MethodLength
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

      action.execute(context)

      future.value!(context.timeout)
    end

    def emit(event_name, payload, options={})
      events = @registry.fetch_events(event_name)

      events.each { |e| e.execute(payload, options) }
    end

    def run # rubocop:disable Metric/MethodLength
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

    def start
      logger.info "starting"
      @transporter.start
      register_local_node
      start_subscribers
      publish_discover
      publish_info
      start_heartbeat
      self
    end

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
      event = @registry.fetch_events_for_node_id(packet.event, Moleculer.node_id)

      event.execute(packet.data)
    end

    def process_request(packet)
      @logger.debug "processing request #{packet.id}"
      action = @registry.fetch_action_for_node_id(packet.action, Moleculer.node_id)
      node   = @registry.fetch_node(packet.sender)

      context = Context.new(
        id:      packet.id,
        broker:  self,
        action:  action,
        params:  packet.params,
        meta:    packet.meta,
        timeout: Moleculer.timeout,
        )

      response = action.execute(context)

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

    private

    def handle_signal(sig)
      case sig
      when "INT", "TERM"
        raise Interrupt
      end
    end

    def publish(packet_type, message = {})
      packet = Packets.for(packet_type).new(message)
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
      @transporter.publish_to_node(packet, node)
    end

    def register_local_node
      logger.info "registering #{Moleculer.services.length} local services"
      node = Node.new(
        node_id:  Moleculer.node_id,
        services: Moleculer.services,
        local:    true,
      )
      @registry.register_node(node)
    end

    def register_or_update_remote_node(info_packet)
      node = Node.from_remote_info(info_packet)
      @registry.register_node(node)
    end

    def register_local_services
      Moleculer.services.each do |service|
        register_service(service)
      end
    end

    def register_service(service)
      @registry.register_local_service(service)
    end

    def start_heartbeat
      Concurrent::TimerTask.new(execution_interval: Moleculer.heartbeat_interval) do
        publish_heartbeat
      end.execute
    end

    def start_subscribers
      subscribe_to_info
      subscribe_to_res
      subscribe_to_req
      subscribe_to_discover
    end

    def subscribe_to_events
      subscribe("MOL.EVENT.#{Moleculer.node_id}") do |packet|
        process_event(packet)
      end
    end

    def subscribe_to_info
      subscribe("MOL.INFO.#{Moleculer.node_id}") do |packet|
        register_or_update_remote_node(packet)
      end
      subscribe("MOL.INFO") do |packet|
        register_or_update_remote_node(packet) unless packet.sender == Moleculer.node_id
      end
    end

    def subscribe_to_res
      subscribe("MOL.RES.#{Moleculer.node_id}") do |packet|
        process_response(packet)
      end
    end

    def subscribe_to_req
      subscribe("MOL.REQ.#{Moleculer.node_id}", min_threads: 10, max_threads: 100) do |packet|
        process_request(packet)
      end
    end

    def subscribe_to_discover
      subscribe("MOL.DISCOVER") do |packet|
        publish_info(packet.sender) unless packet.sender == Moleculer.node_id
      end
      subscribe("MOL.DISCOVER.#{Moleculer.node_id}") do |packet|
        publish_info(packet.sender)
      end
    end

    def subscribe(channel, options = {}, &block)
      @logger.trace "subscribing to channel '#{channel}' with options:", options
      subscribers[channel] = Queue.new(channel, options, &block)
    end

    def subscribers
      @subscribers ||= Concurrent::Hash.new([])
    end
  end
end
