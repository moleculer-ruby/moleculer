# frozen_string_literal: true

require_relative "../registry"

module Moleculer
  module Broker
    ##
    # Registry initialization
    module Registry
      attr_reader :registry

      def initialize(*)
        @registry = Moleculer::Registry.new(self, @options[:registry])
        super
      end
    end
  end
end
