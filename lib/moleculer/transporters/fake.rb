# frozen_string_literal: true

require_relative "base"

module Moleculer
  module Transporters
    ##
    # Fake Transporter for usage in tests
    class Fake < Base
      # @private
      class Bus
        include Wisper::Publisher
      end

      def self.bus
        @@bus ||= Bus.new
      end

      def initialize(broker, options)
        super
        @subscriptions = []
      end

      def subscribe(command, node_id)
        topic = get_topic_name(command, node_id)
      end

      def connect; end

      def disconnect
        @connected = false
      end
    end
  end
end
