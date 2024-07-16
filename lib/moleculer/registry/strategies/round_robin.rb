# frozen_string_literal: true

module Moleculer
  class Registry
    module Strategies
      ##
      # This strategy selects a node based on round-robin algorithm.
      class RoundRobin < Base
        def initialize(registry:, **)
          super

          @index = 0
        end

        def select(list)
          node = list[@index]
          @index = (@index + 1) % list.size

          node
        end
      end
    end
  end
end
