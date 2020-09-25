# frozen_string_literal: true

module Moleculer
  module Service
    class Endpoint
      attr_accessor :service_instance

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
      def call(params = {}, **kwargs)
        return handler.call(service_instance, params, **kwargs) if handler

        service_instance.public_send(method, *args, **kwargs)
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
