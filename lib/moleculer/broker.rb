# frozen_string_literal: true

require_relative "registry"
require_relative "transporters"
require_relative "support"

module Moleculer
  ##
  # The Broker is the primary component of Moleculer. It handles action, events, and communication with remote nodes. Only a single broker should
  # be run for any given process, and it is automatically started when Moleculer::start or Moleculer::run is called.
  class Broker
    include Moleculer::Support
    ##
    # Publisher functions
    module Publishers
      ##
      # Publishes the discover packet
      def publish_discover
        publish(:discover)
      end

      private

      def publish(packet_type, message = {})
        packet = Packets.for(packet_type).new(message)
        @transporter.publish(packet)
      end
    end

    ##
    # Subscriber functions
    module Subscribers
      ##
      # @private
      # A queue is a subscriber thread pool manager allowing Moleculer to handle requests asynchronously
      class Queue
        def initialize(name, options, &block)
          opts      = { max_threads: 1, min_threads: 1, max_queue: 1, fallback_policy: :abort }.merge(options)
          @executor = block
          @pool     = Concurrent::ThreadPoolExecutor.new(opts)
          @name     = name
          @logger   = Moleculer.logger
        end

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

      ##
      # @private
      def process_message(channel, message)
        @logger.trace "no such channel '#{channel}'" unless @subscribers[channel]
        @subscribers[channel] << Packets.for(channel.split(".")[1]).new(message) if @subscribers[channel]
      rescue StandardError => e
        @logger.error e
      end

      private

      def subscribe_to_info
        subscribe("MOL.INFO.#{Moleculer.node_id}") do |packet|
          register_or_update_remote_node(packet)
        end
      end

      def subscribe(channel, options = {}, &block)
        @logger.trace "subscribing to channel '#{channel}' with options:", options
        @subscribers        ||= {}
        @subscribers[channel] = Queue.new(channel, options, &block)
      end
    end

    include Publishers
    include Subscribers

    attr_reader :logger

    def initialize
      @registry    = Registry.new(self)
      @logger      = Moleculer.logger
      @transporter = Transporters.for(Moleculer.transporter, self)
    end

    def run
      start
      trap(:INT) { stop }
      sleep 0.1 while @transporter.started?
    end

    def start
      logger.info "starting"
      @transporter.start
      subscribe_to_info
      publish_discover
      # start_subscriptions
      register_local_node
    end

    def stop
      @logger.info "stopping"
      @transporter.stop
    end

    private

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
      @logger.info "registering remote node '#{info_packet.sender}'" \
                   " on '#{info_packet.hostname}'"
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
  end
end
