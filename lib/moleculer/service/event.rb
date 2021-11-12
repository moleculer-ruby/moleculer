# frozen_string_literal: true

module Moleculer
  module Service
    ##
    # @private
    class Event
      def initialize(opts = {})
        @service = opts.fetch(:service)
        @name    = opts.fetch(:event)
        @handler = opts.fetch(:handler)
        @group   = opts.fetch(:group)
      end

      def call(ctx)
        service.public_send(handler, ctx)
      end

      private

      attr_reader :service, :event, :handler, :params, :cache, :before, :after, :error
    end
  end
end
