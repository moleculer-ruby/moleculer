# frozen_string_literal: true

module Moleculer
  ##
  # A node represents an individual node.
  class Node
    ##
    # @return [Hash] metadata of the node, defaults to `{}`
    attr_reader :metadata

    ##
    # @return [String] the hosname of the node.
    attr_accessor :hostname

    ##
    # @return [String] the id of the node
    attr_reader :id

    ##
    # @return [Boolean] whether the node is local, defaults to `false`
    attr_reader :local

    ##
    # @return [Array<Moleculer::Service>] the services of the node
    attr_accessor :services

    def initialize(info, services: [], local: false)
      @id             = id
      @available      = true
      @last_heartbeat = Time.now
      @local          = local
      @info           = info
      @services       = services.collect(&:new)
    end

    ##
    # @return [Hash] the actions for all services on this node
    def actions
      services.each_with_object({}) do |service, actions|
        actions.merge!(service.actions)
      end
    end

    ##
    # @return [Hash] the events for all services on this node
    def events
      services.each_with_object({}) do |service, events|
        events.merge!(service.events)
      end
    end

  end
end
