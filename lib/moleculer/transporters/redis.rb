# frozen_string_literal: true

require "redis"
require "securerandom"
require "awesome_print"

require_relative "base"

module Moleculer
  module Transporters
    ##
    # Redis transporter
    class Redis < Base
      class << self
        attr_writer :hi_redis

        def hi_redis
          @hi_redis ||= false
        end
      end

      def connect(_reconnect = false)
        @options = { url: @options } if @options.is_a?(String)
        @sub     = ::Redis.new(@options)
        @logger.info("Redis-sub is connected.")
        @pub     = ::Redis.new(@options)
        @logger.info("Redis-pub is connected.")
        make_subscriptions
      end

      def disconnect
        @disconnecting = true
        @sub.disconnect!
        @pub.disconnect!
      end

      def publish(packet, node_id = nil)
        @pub.publish(get_topic_name(packet.type, node_id), serialize(packet))
      end

      def make_subscriptions
        Thread.new do
          topic_names = @subscriptions.map { |topic| get_topic_name(topic[:type].type, topic[:node_id]) }
          @sub.subscribe(*topic_names) do |on|
            on.subscribe do |channel|
              @logger.debug("subscribed to '#{channel}'")
            end
            on.message do |topic, message|
              handle_message({ topic: topic, message: message }.freeze)
            end
          end
        rescue StandardError => e
          raise e unless @disconnecting
        end
      end
    end
  end
end
