# frozen_string_literal: true

require_relative "callable"

module Moleculer
  module Service
    ##
    # Represents a service action
    class Action < Callable
      def initialize(*args, timeout:, cache:, **kwargs, &block)
        super(*args, **kwargs, &block)
        @timeout = timeout
        @cache   = cache
      end

      private

      attr_reader :cache, :timeout
    end
  end
end
