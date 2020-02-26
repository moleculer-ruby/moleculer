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

      def wait_for_services(*services, timeout: 0)
        Timeout.timeout(timeout) do
          sleep 1 until (services - @registry.get_services(*services).keys).empty?
          @logger.debug "waiting for services '#{services.join(', ')}'"
        end
      end
    end
  end
end
