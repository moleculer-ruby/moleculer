# frozen_string_literal: true

module Moleculer
  ##
  # @private
  class Registry
    ##
    # @param [Moleculer::Broker] broker the service broker
    # @param [Moleculer::Node] local_node the local node
    def initialize(broker, local_node)
      @broker     = broker
      @local_node = local_node
    end

    ##
    # Calls a service action.
    #
    # @param [String] endpoint The endpoint of the service.
    # @param [Moleculer::Context] context The context of the request.
    #
    # @return [any] the result of the action.
    def call(endpoint, context)
      call_local_node(endpoint, context)
    end

    ##
    # Calls a service action on the local node.
    #
    # @param [String] endpoint The endpoint of the service.
    # @param [Moleculer::Context] context The context of the request.
    def call_local_node(endpoint, context)
      local_node.call(endpoint, context)
    end

    private

    attr_reader :broker, :local_node
  end
end
