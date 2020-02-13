# frozen_string_literal: true

require_relative "retryable_error"

module Moleculer
  module Errors
    ##
    # A retryable error can be retried
    class RequestTimeoutError < RetryableError
      def initialize(action)
        super("Request is timed out when call '#{action.name}' action on '#{action.node_id}' node.", 504,
              "REQUEST_TIMEOUT", { action: action })
      end
    end
  end
end
