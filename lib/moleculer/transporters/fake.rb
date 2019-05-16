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
        # rubocop:disable Style/ClassVars
        @@subscriptions ||= {}
        # rubocop:enable Style/ClassVars
      end

      def subscribe(channel, &block)
        @@subscriptions[channel] = block
      end

      def publish(packet)
        @@subscriptions[packet.topic].call(packet)
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
