# frozen_string_literal: true

require_relative "context"

module Moleculer
  module Broker
    ##
    # Encapsulates the context for an action
    class ActionContext < Context
      # @return [String] the id of the parent context
      attr_reader :parent_id
      # @return [String] request ID. If you make nested-calls, it will be the same ID.
      attr_reader :request_id

      ##
      # @param parent_id [String] he id of the parent context
      def initialize(parent_id: nil, **kwargs)
        super kwargs
        @parent_id  = parent_id
        @request_id = SecureRandom.hex(24)
      end


      def call(action_name, params = {}, options = {})
        broker.call(
          action_name,
          params,
          options.merge(meta: (@options[:meta] || {}).merge(options[:meta]), parent_context: self),
        )
      end
    end
  end
end
