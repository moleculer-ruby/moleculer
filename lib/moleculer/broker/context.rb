# frozen_string_literal: true

require "forwardable"
require "securerandom"

module Moleculer
  module Broker
    ##
    # When you call an action or emit an event, the broker creates a Context instance that contains all request
    # information and passes it to the action/event handler as a single argument
    class Context
      extend Forwardable
      # @return [String] The Context ID
      attr_reader :id
      # @return [String] Service full name of the caller. E.g.: `v3.myService`
      attr_reader :caller
      # @return [Hash] Request params
      attr_reader :params
      # @return [Hash] Request metadata.
      attr_reader :meta
      # @return [Hash] Local data
      attr_reader :locals
      # @return [Hash] context options
      attr_reader :options
      # @return [String] the request ID
      attr_reader :request_id
      # @return [Context] the parent context
      attr_reader :parent_context

      # @!method emit(event_name, payload = nil, groups = [])
      # @return [Boolean]
      # @see Moleculer::Broker::Events#emit

      # @!method broadcast(event_name, payload = nil, groups = [])
      # @return [Boolean]
      # @see Moleculer::Broker::Events#broadcast

      # @!attribute node_id
      # @return [String] the caller or target Node ID

      # @!attribute broker
      # @return [Moleculer::Broker::Base] the service broker instance

      def_delegators :broker, :emit, :broadcast
      def_delegators :@endpoint, :node_id, :broker

      ##
      # @param params [Hash] request params
      # @param endpoint [Moleculer::Service::Endpoint] the endpoint for this context
      # @param meta [Hash] request metadata
      # @param locals [Hash] local data
      # @param options [Hash] context options
      def initialize(params: {}, endpoint:, meta: {}, locals: {}, options:, parent_context: nil)
        @id             = SecureRandom.hex(24)
        @params         = params
        @endpoint       = endpoint
        @options        = options
        @request_id     = SecureRandom.hex(24)
        @meta           = meta
        @locals         = locals
        @parent_context = parent_context
      end

      ##
      # Calls a service within a sub context
      # @see Moleculer::Broker::Actions#call
      def call(action_name, params = {}, options = {})
        opts = options.merge(parent_context: self)

        if options[:timeout]
          diff = Time.now.to_i - @start_time.to_i

          opts[:timeout] = options[:timeout] - diff
        end

        broker.call(action_name, params, opts)
      end

      # @private
      def execute(&block)
        @start_time = Time.now
        yield self
      end
    end
  end
end
