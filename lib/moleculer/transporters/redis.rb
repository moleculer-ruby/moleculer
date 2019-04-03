require "redis"

# frozen_string_literal: true

module Moleculer
  module Transporters
    ##
    # The Moleculer Redis transporter
    class Redis
      ##
      # Represents the publisher connection
      class Publisher
        def initialize
          @uri        = Moleculer.transporter
          @logger     = Moleculer.logger
          @serializer = Serializers.for(Moleculer.serializer)
        end

        ##
        # Publishes the packet to the packet's topic
        def publish(packet)
          @logger.trace "publishing packet to '#{packet.topic}'", packet.as_json
          connection.publish(packet.topic, @serializer.serialize(packet))
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
      class Subscriber
        ##
        # Represents a subscription
        class Subscription
          attr_reader :disconnect_hash, :channel
          ##
          # handles processing of messages from redis
          class MessageProcessor
            def initialize(subscription)
              @subscription = subscription
              @serializer   = Serializers.for(Moleculer.serializer)
              @packet_type  = Packets.for(@subscription.channel.split(".")[1])
              @logger       = Moleculer.logger
            end

            def process(message)
              return :disconnect if message == @subscription.disconnect_hash

              return nil if message.split(".")[-1] == "disconnect"

              parsed = @serializer.deserialize(message)
              return nil if parsed["sender"] == Moleculer.node_id

              @packet_type.new(parsed)
            rescue StandardError => e
              @logger.error e
            end
          end

          def initialize(channel, block)
            @connection  = ::Redis.new(url: @uri)
            @channel     = channel
            @block       = block
            @logger      = Moleculer.logger

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
                    packet = MessageProcessor.new(self).process(message)
                    next unless packet

                    process_packet(packet)
                  end
                end
              rescue StandardError => e
                @logger.fatal e
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
            @disconnect_hash.set("#{Moleculer.node_id}.#{SecureRandom.hex}.disconnect")
          end

          def process_packet(packet)
            return @connection.unsubscribe if packet == :disconnect

            @block.call(packet)
          rescue StandardError => e
            @logger.error e
          end

          private

          def unsubscribe
            @logger.debug "disconnecting channel '#{@channel}'"
            @connection.disconnect!
          end
        end

        def initialize
          @uri           = Moleculer.transporter
          @logger        = Moleculer.logger
          @subscriptions = Concurrent::Array.new
        end

        def subscribe(channel, &block)
          @logger.debug "subscribing to channel '#{channel}'"
          @subscriptions << Subscription.new(channel, block).connect
        end

        def disconnect
          @logger.debug "disconnecting subscriptions"
          @subscriptions.each(&:disconnect)
        end
      end

      def subscribe(channel, &block)
        subscriber.subscribe(channel, &block)
      end

      def publish(packet)
        publisher.publish(packet)
      end

      def connect
        publisher.connect
      end

      def disconnect
        publisher.disconnect
        subscriber.disconnect
      end

      private

      def publisher
        @publisher ||= Publisher.new
      end

      def subscriber
        @subscriber ||= Subscriber.new
      end
    end
  end
end
