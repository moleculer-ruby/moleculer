# frozen_string_literal: true

module Moleculer
  module Service
    class Callable
      def initialize(service, name:, method:, &block)
        @service = service
        @name    = name
        @method  = method
        @handler = block
      end

      ##
      # Calls the action
      #
      # @param [*Array] args to call the action with
      # @param [**Hash] the keyword args to acall the action with
      def call(*args, **kwargs)
        return handler.call(*args, **kwargs) if handler

        service.public_send(method, *args, **kwargs)
      end

      private

      attr_reader :service, :name, :method, :handler
    end
  end
end
