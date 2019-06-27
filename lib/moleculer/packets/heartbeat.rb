require_relative "base"

module Moleculer
  module Packets
    ##
    # Represents a DISCOVER packet
    class Heartbeat < Base

      def initialize(broker, data)
        super(broker, data)

        @cpu = 0
      end


    end
  end
end
