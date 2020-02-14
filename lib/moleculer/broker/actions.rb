# frozen_string_literal: true

require "concurrent/hash"
require_relative "../context"

module Moleculer
  module Broker
    ##
    # Broker actions
    module Actions
      def initialize(*)
        @pending_requests = Concurrent::Hash.new
        super
      end

      ##
      # @private
      def add_response(response)
        @pending_requests[response.payload[:id]] = response.payload
      end

      ##
      # Call an action
      #
      # @param action_name [String] name of action
      # @param params [Hash] params of action
      # @param options [Hash] options of call
      def call(action_name, params = nil, options = {})
        endpoint = get_action_endpoint(action_name, options[:node_id])
        context  = Context.new(params: params, broker: self, endpoint: endpoint, options: options)
        call_endpoint(endpoint, context)
      rescue TimeoutError
        @pending_requests.delete(context.request_id)
        raise Errors::RequestTimeoutError, endpoint
      rescue StandardError => e
        @pending_requests.delete(context.request_id) if context
        raise e
      end

      ##
      # @private
      def process_response(response)
        raise Errors.recreate_error(response[:error]) unless response[:success]

        response[:data]
      end

      ##
      # @private
      def send_action(endpoint, context)
        @transit.send_action(endpoint, context)
      end

      private

      def get_action_endpoint(action_name, node_id)
        endpoint = @registry.get_action_endpoint(action_name, node_id)
        raise Errors::ServiceNotFound, action_name, node_id unless endpoint

        endpoint
      end

      def call_endpoint(endpoint, context)
        endpoint.call(context)
        wait_for_context(context)
        process_response(@pending_requests.delete(context.request_id))
      end

      def wait_for_context(context)
        Timeout.timeout(@options[:request_timeout]) do
          sleep 0.1 until @pending_requests[context.request_id]
        end
      end

    end
  end
end
