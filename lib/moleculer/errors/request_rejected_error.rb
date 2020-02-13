# frozen_string_literal: true

require_relative "retryable_error"

module Moleculer
  module Errors
    ##
    # A retryable error can be retried
    class RequestRejectedError < RetryableError
      def initialize(action)
        super("Request is rejected when call '#{action.name}' action on '#{action.node_id}' node.", 503, "REQUEST_REJECTED", {action: action});
      end
    end
  end
end
