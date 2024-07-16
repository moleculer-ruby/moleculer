# frozen_string_literal: true

module Moleculer
  class Registry
    ##
    # Represents a node in the registry.
    class Node
      ##
      # @param [String] id The node ID
      def initialize(id:)
        @id = id
      end
    end
  end
end
