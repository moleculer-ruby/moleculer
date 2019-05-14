require "redis"
require_relative "base"

# frozen_string_literal: true

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
          @logger     = config.logger.get_child("[REDIS.TRANSPORTER.PUBLISHER]")
          @serializer = Serializers.for(config.serializer).new(config)
        end

        ##
        # Publishes the packet to the packet's topic
        def publish(packet)
          topic = packet.topic
          @logger.debug  "publishing packet to '#{topic}'", packet.as_json
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
          def initialize(config:, channel:, block:)
            @connection  = ::Redis.new(url: config.transporter)
            @channel     = channel
            @block       = block
            @logger      = config.logger.get_child("[REDIS.TRANSPORTER.SUBSCRIPTION.#{channel}]")
            @serializer  = Serializers.for(config.serializer).new(config)
            @node_id     = config.node_id

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
                    packet = process_message(message)
                    next unless packet

                    process_packet(packet)
                  end
                end
              rescue StandardError => error
                @logger.fatal error
                exit 1
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

          def deserialize(message)
            parsed = @serializer.deserialize(message)
            return nil if parsed["sender"] == @node_id

            parsed
          end

          def message_is_disconnect?(message)
            message.split(".")[-1] == "disconnect"
          end

          def process_packet(packet)
            return @connection.unsubscribe if packet == :disconnect

            @logger.trace "received packet from #{packet.sender}:", packet.as_json

            @block.call(packet)
          rescue StandardError => error
            @logger.error error
          end

          def process_message(message)
            return :disconnect if message == @disconnect_hash

            return nil if message_is_disconnect?(message)

            packet_type = Packets.for(@channel.split(".")[1])

            parsed = deserialize(message)

            return nil unless parsed


            packet_type.new(parsed)
          rescue StandardError => error
            @logger.error error
          end

          def unsubscribe
            @logger.debug "disconnecting channel '#{@channel}'"
            @connection.disconnect!
          end
        end

        def initialize(config)
          @config        = config
          @uri           = config.transporter
          @logger        = config.logger.get_child("[REDIS.TRANSPORTER]")
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

          @subscriptions.last.connect if @started
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

      def connect
        publisher.connect
        subscriber.connect
      end

      def disconnect
        publisher.disconnect
        subscriber.disconnect
      end

      def start
        connect
      end

      def stop
        disconnect
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
