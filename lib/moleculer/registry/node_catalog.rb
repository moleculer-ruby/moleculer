# frozen_string_literal: true

module Moleculer
  class Registry
    ##
    # Represents a catalog of nodes in the registry.
    class NodeCatalog
      include Concerns::Logger

      ##
      # @param [Moleculer::Registry] registry The registry instance
      def initialize(registry:)
        @registry = registry
        @nodes = {}
      end
    end
  end
end
