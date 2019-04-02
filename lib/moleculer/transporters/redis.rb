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
          def initialize(channel, block)
            @connection  = ::Redis.new(url: @uri)
            @channel     = channel
            @block       = block
            @logger      = Moleculer.logger
            @serializer  = Serializers.for(Moleculer.serializer)
            @packet_type = Packets.for(@channel.split(".")[1])
            # it is necessary to send some sort of message to signal the subscriber to disconnect and shutdown
            # this is an internal message
            set_disconnect
          end

          ##
          # Starts the subscriber
          def connect
            @thread = Thread.new do
              begin
                @logger.debug "starting subscription to '#{@channel}'"
                @connection.subscribe(@channel) do |on|
                  on.unsubscribe do
                    @logger.debug "disconnecting channel '#{@channel}'"
                    @connection.disconnect!
                  end

                  on.message do |_, message|
                    if message == @disconnect_hash.value
                      @connection.unsubscribe
                    elsif message.split(".")[-1] != "disconnect"
                      begin
                        set_disconnect
                        parsed = @serializer.deserialize(message)
                        if parsed && parsed["sender"] != Moleculer.node_id
                          @logger.trace "received message '#{@channel}'", parsed
                          packet = @packet_type.new(parsed)
                          @block.call(packet)
                        end
                      rescue StandardError => e
                        @logger.error e
                      end
                    end
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

          private

          def set_disconnect
            @disconnect_hash ||= Concurrent::AtomicReference.new
            @disconnect_hash.set("#{Moleculer.node_id}.#{SecureRandom.hex}.disconnect")
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
