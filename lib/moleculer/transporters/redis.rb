# frozen_string_literal: true

require "uri"
require "redis"
require "concurrent/actor"
require "concurrent/actor/utils/ad_hoc"

require_relative "base"

module Moleculer
  module Transporters
    ##
    # Redis transporter.
    class Redis < Base
      include Concurrent::Actor::Utils

      def connect
        logger.info("connecting to Redis", config)
        @publisher  = ::Redis.new(config)
        @subscriber = ::Redis.new(config)

        @subscriptions = {}

        Thread.new do
          subscriber.psubscribe("#{prefix}*") do |on|
            on.pmessage do |_pattern, channel, message|
              subscriptions[channel] << message
            end
          end
        end
        self
      end

      def subscribe(cmd, &block)
        logger.info("subscribing to topic '#{cmd}'")
        subscriptions[cmd] = AdHoc.spawn(
          name:                 cmd,
          supervise:            true,
          behaviour_definition: Concurrent::Actor::Behaviour.restarting_behaviour_definition,
        ) { ->(message) { block.call(message) } }
      end

      def disconnect
        subscriber.close
        publisher.close
      end

      private

      attr_reader :publisher, :subscriber, :subscriptions
    end
  end
end
