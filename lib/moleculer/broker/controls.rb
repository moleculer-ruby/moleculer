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

      def start
        @transit.connect
      end

      def stop; end
    end
  end
end
