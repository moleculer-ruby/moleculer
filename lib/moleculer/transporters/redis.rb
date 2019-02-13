require "redis"

# frozen_string_literal: true

require_relative "./base"

module Moleculer
  module Transporters
    class Redis < Base
      NAME = "Redis".freeze

      def connect
        @broker.logger.info "Connecting to Redis transporter"
        @redis = ::Redis.new(url: @uri)
        @subscriptions = {}
        @redis_thread = Thread.new do
          @redis.psubscribe("MOL.*") do |on|
            on.message do |channel, message|
              if sub = @subscriptions[channel]
                sub[:handler].call(sub[:packet].from(message))
              end
            end
          end
        end
      end

      def join
        @redis_thread.join
      end

      def publish(packet)
        @broker.logger.debug "Broadcasting #{packet.name} packet"
        @redis.publish(packet.topic, packet.serialize)
      end

      def subscribe(topic, packet, &block)
        @subscriptions[topic] = { packet: packet, handler: block }
      end
    end
  end
end
