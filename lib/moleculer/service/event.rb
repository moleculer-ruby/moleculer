# frozen_string_literal: true

require_relative "callable"

module Moleculer
  module Service
    class Event < Callable
      def initialize(*args, group:, **kwargs)
        super(*args, **kwargs)
        @group = group
      end

      private

      attr_reader :group
    end
  end
end
