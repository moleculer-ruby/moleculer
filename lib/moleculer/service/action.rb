# frozen_string_literal: true

require_relative "callable"

module Moleculer
  module Service
    ##
    # Represents a service action
    class Action < Callable
      def initialize(*args, timeout:, cache:, **kwargs, &block)
        super(*args, **kwargs, &block)
        @timeout  = timeout
        @cache    = cache
      end

      def raw_name
        @name
      end

      def name
        "#{service.service_name}.#{raw_name}"
      end

      def schema
        super.merge(
          cache: cache,
          raw_name: raw_name,
          name: name,
          params: {},
          metrics: {
            params: false,
            meta: false
          }
        )
      end

      private

      attr_reader :cache, :timeout
    end
  end
end
