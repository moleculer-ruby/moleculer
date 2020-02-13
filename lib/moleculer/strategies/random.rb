# frozen_string_literal: true

module Moleculer
  module Strategies
    ##
    # Returns an action on a random node
    class Random
      def select(list)
        list[rand(list.length) - 1]
      end
    end
  end
end
