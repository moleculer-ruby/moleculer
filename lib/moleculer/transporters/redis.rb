require "redis"
require "concurrent-ruby"

# frozen_string_literal: true

require_relative "./base"

module Moleculer
  module Transporters
    class Redis < Base
      include Concurrent::Async
      NAME = "Redis".freeze

      def initialize(broker, uri)
        @subscriptions = Concurrent::Map.new
        super
      end

      def connect
        @broker.logger.info "Connecting to Redis transporter"
        @subscriber = ::Redis.new(url: @uri, logger: @broker.logger)
        @subscriber.psubscribe("MOL*") do |on|
          on.psubscribe do |channel, subscriptions|
            @broker.logger.debug "Subscribed to #{channel} (#{subscriptions} subscriptions)"
          end
          on.pmessage do |_, message, data|
            begin
              @broker.logger.debug "received packet '#{message}'"
              sub = @subscriptions[message]
              if sub
                sub[:handler].call(sub[:packet].from(data))
              end
            rescue StandardError => e
              @broker.logger.error e
            end
          end
        end
      end

      def publish(packet)
        @broker.logger.debug "publishing #{packet.name} packet"
        publisher.publish(packet.topic, packet.serialize)
      end

      def subscribe(topic, packet, &block)
        @subscriptions[topic] = { packet: packet, handler: block }
      end

      private

      def publisher
        @publisher ||= ::Redis.new(url: @uri, logger: @broker.logger)
      end
    end
  end
end
