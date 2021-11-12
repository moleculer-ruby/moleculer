# frozen_string_literal: true

module Moleculer
  module Service
    # @private
    class Action
      def initialize(opts = {})
        @service = opts.fetch(:service)
        @name    = opts.fetch(:name)
        @handler = opts.fetch(:handler)
        @params  = opts.fetch(:params)
        @cache   = opts.fetch(:cache)
        @before  = opts.fetch(:before)
        @after   = opts.fetch(:after)
        @error   = opts.fetch(:error)
      end

      ##
      # Calls the action on the service with the provided context
      #
      # @param [Moleculer::Context] ctx the context to call the action with
      #
      # @return [any] the result of the action
      def call(ctx)
        service.public_send(handler, ctx)
      end

      ##
      # @return [Hash] hash representation of the action
      def to_info
        {
          name:   name,
          params: params,
        }
      end

      private

      attr_reader :service, :name, :handler, :params, :cache, :before, :after,
                  :error
    end
  end
end
