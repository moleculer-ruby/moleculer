# frozen_string_literal: true

module Moleculer
  module Service
    # @private
    class Action
      def initialize(opts = {})
        @service  = opts.fetch(:service)
        @endpoint = opts.fetch(:endpoint)
        @handler  = opts.fetch(:handler)
        @params   = opts.fetch(:params)
        @cache    = opts.fetch(:cache)
        @before   = opts.fetch(:before)
        @after    = opts.fetch(:after)
        @error    = opts.fetch(:error)
      end

      def call(ctx)
        service.public_send(handler, ctx)
      end

      private

      attr_reader :service, :endpoint, :handler, :params, :cache, :before, :after,
                  :error
    end
  end
end
