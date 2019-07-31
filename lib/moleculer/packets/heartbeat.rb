# frozen_string_literal: true

require_relative "base"

module Moleculer
  module Packets
    ##
    # Represents a DISCOVER packet
    class Heartbeat < Base
      def initialize(config, data = {})
        super(config, data)

        @cpu = 0
      end
    end
  end
end
