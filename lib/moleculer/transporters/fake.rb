# frozen_string_literal: true

require_relative "base"

module Moleculer
  module Transporters
    ##
    # The fake transporter is designed to be used in testing. It is simply an in memory queue and should not be used
    # in production.
    class Fake < Base
      def initialize(config)
        super(config)
        # in this case we want to use a class var as this needs to behave like a singleton to mimic how a global
        # transporter functions
        @@subscriptions ||= {} # rubocop:disable Style/ClassVars
        @logger           = config.logger.get_child("[FAKE.TRANSPORTER-#{config.node_id}]")
      end

      def subscribe(channel, &block)
        @@subscriptions[channel] ||= []
        @@subscriptions[channel] << block
      end

      def publish(packet)
        @logger.debug "publishing packet to '#{packet.topic}'", packet.to_h
        @@subscriptions[packet.topic].collect  do |c|
          @logger.debug "processing #{@@subscriptions[packet.topic].index(c) +1} of #{@@subscriptions[packet.topic].length} callbacks for '#{packet.topic}'"
          c.call(packet)
        end
      end

      def start
        true
      end

      def stop
        true
      end
    end
  end
end
