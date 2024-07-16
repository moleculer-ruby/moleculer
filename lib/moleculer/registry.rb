# frozen_string_literal: true

module Moleculer
  ##
  # Moleculer has a built-in service registry class. It stores all information about services, actions, event listeners
  # and nodes. When you call a service or emit an event, broker asks the registry to look up a node which is able to
  # execute the request. If there are multiple nodes, it uses load-balancing strategy to select the next node.
  class Registry
    extend Forwardable

    ##
    # @param broker [Moleculer::Broker] the broker instance
    # @param strategy [Class<Strategies::RoundRobin>] the strategy class
    # @param strategy_options [Hash] the options for the strategy.
    # @param discoverer [Class<Discoverer::Base>] the discoverer class.
    # @param discoverer_options [Hash] the options for the discoverer.
    def initialize(
      broker:,
      strategy: Strategies::RoundRobin,
      strategy_options: {},
      discoverer: Discoverers::Local,
      discoverer_options: {}
    )
      @broker = broker

      @strategy = strategy.new(registry: self, **strategy_options)
      logger.info("Strategy: #{strategy.name}")

      @discoverer = discoverer.new(registry: self, **discoverer_options)
      logger.info("Discoverer: #{discoverer.name}")
    end

    private

    attr_reader :strategy, :discoverer, :broker

    def_delegator :broker, :logger
  end
end

require_relative "registry/discoverers"
require_relative "registry/strategies"
require_relative "registry/node"
