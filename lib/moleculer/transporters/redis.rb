# frozen_string_literal: true

require "redis"
require_relative "base"

module Moleculer
  module Transporters
    ##
    # The Moleculer Redis transporter
    class Redis < Base
      ##
      # @private
      # Represents the publisher connection
      class Publisher
        def initialize(config)
          @uri        = config.transporter
          @logger     = config.logger.get_child("[REDIS.TRANSPORTER.PUBLISHER.#{config.node_id}]")
          @serializer = Serializers.for(config.serializer).new(config)
        end

        ##
        # Publishes the packet to the packet's topic
        def publish(packet)
          topic = packet.topic
          @logger.trace "publishing packet to '#{topic}'", packet.to_h
          connection.publish(topic, @serializer.serialize(packet))
        end

        ##
        # Connects to redis
        def connect
          @logger.debug "connecting publisher client on '#{@uri}'"
          connection
        end

        ##
        # Disconnects from redis
        def disconnect
          @logger.debug "disconnecting publisher client"
          connection.disconnect!
        end

        private

        def connection
          @connection ||= ::Redis.new(url: @uri)
        end
      end

      ##
      # Represents the subscriber connection
      # @private
      class Subscriber
        ##
        # Represents a subscription
        class Subscription
          ##
          # @param [Moleculer::Configuration]
          def initialize(config:, channel:, block:)
            @connection = ::Redis.new(url: config.transporter)
            @channel    = channel
            @block      = block
            @logger     = config.logger.get_child("[REDIS.TRANSPORTER.SUBSCRIPTION.#{config.node_id}.#{channel}]")
            @serializer = Serializers.for(config.serializer).new(config)
            @node_id    = config.node_id
            @config     = config

            # it is necessary to send some sort of message to signal the subscriber to disconnect and shutdown
            # this is an internal message
            reset_disconnect
          end

          ##
          # Starts the subscriber
          def connect
            @thread = Thread.new do
              begin
                @logger.debug "starting subscription to '#{@channel}'"
                @connection.subscribe(@channel) do |on|
                  on.unsubscribe do
                    unsubscribe
                  end

                  on.message do |_, message|
                    @logger.trace "received message #{message}"
                    packet = process_message(message)
                    next unless packet

                    process_packet(packet)
                  end
                end
              rescue StandardError => e
                @config.handle_error(e)
              end
            end
            self
          end

          def disconnect
            @logger.debug "unsubscribing from '#{@channel}'"
            redis = ::Redis.new(url: @uri)
            redis.publish(@channel, @disconnect_hash.value)
            redis.disconnect!
          end

          def reset_disconnect
            @disconnect_hash ||= Concurrent::AtomicReference.new
            @disconnect_hash.set("#{@node_id}.#{SecureRandom.hex}.disconnect")
          end

          private

          def deserialize(type, message)
            @logger.trace "attempting to deserialize packet #{type}"
            packet = @serializer.deserialize(type, message)
            if packet.sender == @node_id
              @logger.warn "sender was THIS node"
              return nil
            end

            packet
          end

          def message_is_disconnect?(message)
            message.split(".")[-1] == "disconnect"
          end

          def process_packet(packet)
            return @connection.unsubscribe if packet == :disconnect

            @logger.trace "received packet from #{packet.sender}:", packet.to_h

            @block.call(packet)
          rescue StandardError => e
            @config.handle_error(e)
          end

          def process_message(message)
            return :disconnect if message == @disconnect_hash

            return nil if message_is_disconnect?(message)

            type   = @channel.split(".")[1].downcase.to_sym
            @logger.trace "received packet type #{type}"
            packet = deserialize(type, message)

            return nil unless packet

            packet
          rescue StandardError => e
            @config.handle_error(e)
          end

          def unsubscribe
            @logger.debug "disconnecting channel '#{@channel}'"
            @connection.disconnect!
          end
        end

        def initialize(config)
          @config        = config
          @uri           = config.transporter
          @logger        = config.logger.get_child("[REDIS.TRANSPORTER.#{@config.node_id}]")
          @subscriptions = Concurrent::Array.new
          @started       = false
        end

        def subscribe(channel, &block)
          @logger.debug "subscribing to channel '#{channel}'"
          @subscriptions << Subscription.new(
            channel: channel,
            block:   block,
            config:  @config,
          )

          @subscriptions.last.connect if started?
        end

        def disconnect
          @logger.debug "disconnecting subscriptions"
          @subscriptions.each(&:disconnect)
        end

        def connect
          @logger.debug "connecting subscriptions"
          @subscriptions.each(&:connect)
          @started = true
        end

        def started?
          @started
        end
      end

      def initialize(config)
        @config = config
      end

      def subscribe(channel, &block)
        subscriber.subscribe(channel, &block)
      end

      def publish(packet)
        publisher.publish(packet)
      end

      def start
        publisher.connect
        subscriber.connect
      end

      def stop
        publisher.disconnect
        subscriber.disconnect
      end

      private

      def publisher
        @publisher ||= Publisher.new(@config)
      end

      def subscriber
        @subscriber ||= Subscriber.new(@config)
      end
    end
  end
end
