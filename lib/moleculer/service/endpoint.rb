# frozen_string_literal: true

module Moleculer
  module Service
    class Endpoint
      def initialize(service, name:, method:, &block)
        @service  = service
        @name     = name
        @method   = method || name unless block_given?
        @handler  = block
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

      def schema
        {
          name: name,
        }
      end

      private

      attr_reader :service, :name, :method, :handler, :raw_name
    end
  end
end
