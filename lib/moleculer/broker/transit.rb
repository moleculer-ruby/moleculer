# frozen_string_literal: true

require_relative "../transit"

module Moleculer
  module Broker
    ##
    # Transit initialization
    module Transit
      def initialize(*)
        @transit = Moleculer::Transit.new(self, @options[:transit])
        super
      end
    end
  end
end
