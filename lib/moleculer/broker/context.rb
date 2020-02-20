# frozen_string_literal: true

module Moleculer
  module Broker
    ##
    # When you call an action or emit an event, the broker creates a Context instance that contains all request
    # information and passes it to the action/event handler as a single argument
    class Context
      # @return [String] The Context ID
      attr_reader :id
      # @return [Moleculer::Broker] the broker instance
      attr_reader :broker
      # @return [String] The caller or target Node ID
      attr_reader :node_id
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

      ##
      # @param params [Hash] request params
      # @param broker [Moleculer::Broker] the broker instance
      # @param endpoint [Moleculer::Service::Endpoint] the endpoint for this context
      # @param meta [Hash] request metadata
      # @param locals [Hash] local data
      # @param options [Hash] context options
      def initialize(params: {}, broker:, endpoint:, meta: {}, locals: {}, options:)
        @id         = SecureRandom.hex(24)
        @broker     = broker
        @params     = params
        @endpoint   = endpoint
        @options    = options
        @request_id = SecureRandom.hex(24)
        @node_id    = endpoint.node_id
        @meta       = meta
        @locals     = locals
      end
    end
  end
end
