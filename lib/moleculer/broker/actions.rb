# frozen_string_literal: true

require "concurrent/hash"
require_relative "../context"

module Moleculer
  module Broker
    ##
    # The actions are the callable/public methods of the service. The action calling represents a remote-procedure-call
    # (RPC). It has request parameters & returns response, like a HTTP request.
    #
    # If you have multiple instances of services, the broker will load balance the request among instances.
    module Actions
      # @private
      def initialize(*)
        @pending_requests = Concurrent::Hash.new
        super
      end

      # @private
      def add_response(response)
        @pending_requests[response.payload[:id]] = response.payload
      end

      ##
      # To call a service use the broker.call method. The broker looks for the service (and a node) which has the given
      # action and calls it.
      #
      # @param action_name [String]  a dot-separated string. The first part of it is the service name, while the second
      #   part of it represents the action name. So if you have a posts service with a create action, you can call it as
      #   `posts.create`
      # @param params [Hash] a `Hash` which is passed to the action as a part of the `Context`. The service
      #   can access it via `ctx.params`
      # @param options [Hash] an `Hash` to set/override some request parameters, e.g.: `timeout`, `retry_count`.
      # @option options [Integer] :timeout Timeout of request in milliseconds. If the request is timed out and you don't
      #   define `:fallback_response`, broker will throw a RequestTimeout error. To disable set `0`. If it's not defined
      #   , the `request_timeout` value from broker options will be used.
      # @option options [Integer] :retries count of retry of request. If the request is timed out, broker will try to
      #   call again. To disable set `0`. If it's not defined, the `retry_policy.retries` value from broker options will
      #   be used.
      # @option options [Hash] :fallback_response response to be returned if the request has failed.
      # @option options [String] :node_id target node_id. If set, it will make a direct call to the specified node.
      # @option options [Hash] :meta ({}) metadata of request. Access it via `ctx.meta` in actions handlers. It will be
      #   transferred & merged at nested calls, as well.
      #
      # @example Call without params
      #   response = broker.call("user.list")
      #
      # @example Call with params
      #   response = broker.call("user.get", { id: 3 })
      #
      # @example Direct call: get health info from the `node-21` node
      #    broker.call("$node.health", null, { node_id: "node-21" })
      def call(action_name, params = {}, options = {})
        retries  = options[:retries] || @options.dig(:retry_policy, :retries) || 0
        endpoint = get_action_endpoint(action_name, options[:node_id])
        context  = Context.new(params: params, broker: self, endpoint: endpoint, options: options)
        call_endpoint(context, endpoint)
      rescue StandardError => e
        handle_error(e, retries, context.request_id)
        call(action_name, params, options.merge(retries: retries - 1))
      end

      # @private
      def process_response(response)
        raise Errors.recreate_error(response[:error]) unless response[:success]

        response[:data]
      end

      # @private
      def send_action(endpoint, context)
        @transit.send_action(endpoint, context)
      end

      private

      def handle_error(error, retries, request_id)
        return if error.is_a?(Errors::RetryableError) && (retries - 1).positive?

        @pending_requests.delete(request_id)
        raise error
      end

      def get_action_endpoint(action_name, node_id)
        endpoint = @registry.get_action_endpoint(action_name, node_id)
        raise Errors::ServiceNotFound, action_name, node_id unless endpoint

        endpoint
      end

      def call_endpoint(context, endpoint)
        endpoint.call(context)
        wait_for_context(context, endpoint)
        process_response(@pending_requests.delete(context.request_id))
      end

      def wait_for_context(context, endpoint)
        Timeout.timeout(context.options[:timeout] || @options[:request_timeout]) do
          sleep 0.1 until @pending_requests[context.request_id]
        end
      rescue Timeout::Error
        raise Errors::RequestTimeoutError, endpoint
      end
    end
  end
end
