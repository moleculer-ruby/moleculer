# frozen_string_literal: true

require_relative "registry"
require_relative "transporters"

module Moleculer
  ##
  # The Broker is the primary component of Moleculer. It handles action, events, and communication with remote nodes. Only a single broker should
  # be run for any given process, and it is automatically started when Moleculer::start or Moleculer::run is called.
  class Broker
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
      # A queue is a subscriber threadpool manager allowing Moleculer to handle requests asynchronously
      class Queue
        def initialize(name, options, &block)
          opts      = { max_threads: 1, min_threads: 1, max_queue: 1, fallback_policy: :abort }.merge(options)
          @executor = block
          @pool     = Concurrent::ThreadPoolExecutor.new(opts)
          @name     = name
          @logger   = Moleculer.logger
        end

        def <<(message)
          begin
            packet = Packets.for(@name).new(message)
          rescue StandardError => e
            @logger.error e
          end
          @pool.post do
            @executor.call(packet)
          end
        end
      end

      ##
      # @private
      def process_message(channel, message)
        @subscribers[channel.split(".")[1]] << message if @subscribers[channel.split(".")[1]]
      end

      private

      def subscribe_to_info
        subscribe("INFO") do |packet|
          packet
        end
      end

      def subscribe(channel, options = {}, &block)
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
      # subscribe_to_info
      # publish_discover
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
      node = Node::Local.new(
        node_id:  Moleculer.node_id,
        services: Moleculer.services,
      )
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
