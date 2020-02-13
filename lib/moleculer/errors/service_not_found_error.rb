# frozen_string_literal: true

require_relative "retryable_error"

module Moleculer
  module Errors
    ##
    # A retryable error can be retried
    class ServiceNotFound < RetryableError
      def initialize(action_name, node_id = nil)
        msg = if node_id
                "Service '#{action_name}' is not found on '#{node_id}'"
              else
                "Service '#{action_name}' is not found."
              end
        super(msg, 404, "SERVICE_NOT_FOUND", { node_id: node_id, action_name: action_name })
      end
    end
  end
end
