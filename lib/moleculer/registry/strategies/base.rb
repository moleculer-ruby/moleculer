# frozen_string_literal: true

module Moleculer
  class Registry
    module Strategies
      ##
      # Moleculer has several built-in load balancing strategies. If a service is running on multiple node instances,
      # `Moleculer::Registry` uses these strategies to select a single node from the available ones. This class is the
      # base class for all load balancing strategies.
      class Base
        ##
        # @param [Moleculer::Registry] registry The registry instance
        def initialize(registry:, **)
          @registry = registry
        end

        # Override this method in your strategy to select a node from the list of available nodes.
        # @param [Array<Moleculer::Registry::Node>] list The list of available nodes
        # @return [Moleculer::Registry::Node] The selected node
        def select(list)
          raise NotImplementedError
        end
      end
    end
  end
end
