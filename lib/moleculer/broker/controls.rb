# frozen_string_literal: true

module Moleculer
  module Broker
    ##
    # Broker start stop controls
    module Controls
      def initialize(*)
        @started = false
        super
      end

      ##
      # Starts the broker
      def start
        @transit.connect
        @started = true
      end

      ##
      # Stops the broker
      def stop
        @transit.disconnect
      end
    end
  end
end
