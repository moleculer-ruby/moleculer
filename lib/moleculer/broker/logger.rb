# frozen_string_literal: true

require_relative "../logger"

module Moleculer
  module Broker
    ##
    # Broker logging abilities
    module Logger
      # @return [::Logger] the broker logger
      attr_reader :logger

      include Moleculer::Logger

      # @private
      def initialize(*)
        @logger = get_logger("BROKER")
      end

      def get_logger(*tags)
        super(tags.unshift(@node_id))
      end
    end
  end
end
