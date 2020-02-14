# frozen_string_literal: true

require "concurrent/hash"
require_relative "../context"

module Moleculer
  module Broker
    ##
    # Broker actions
    module Actions
      def initialize(*)
        @pending_requests ||= Concurrent::Hash.new
        super
      end

      def add_response(response)
        @pending_requests[response.payload[:id]] = response.payload
      end

      def call(action_name, params = nil, options = {})
        endpoint = get_action_endpoint(action_name, options[:node_id])
        context  = Context.new(params: params, broker: self, endpoint: endpoint, options: options)
        endpoint.call(context)
        Timeout.timeout(@options[:request_timeout]) do
          wait_for_context(context)
        end
        process_response(@pending_requests.delete(context.request_id))
      rescue TimeoutError
        @pending_requests.delete(context.request_id)
        raise Errors::RequestTimeoutError, action
      rescue => e
        @pending_requests.delete(context.request_id) if context
        raise e
      end

      def get_action_endpoint(action_name, node_id)
        endpoint = registry.get_action_endpoint(action_name, node_id)
        raise Errors::ServiceNotFound, action_name, node_id unless endpoint

        endpoint
      end

      def process_response(response)
        raise Errors.recreate_error(response[:error]) unless response[:success]

        response[:data]
      end

      def send_action(endpoint, context)
        transit.send_action(endpoint, context)
      end

      private

      def wait_for_context(context)
        sleep 0.1 until @pending_requests[context.request_id]
      end

    end
  end
end
