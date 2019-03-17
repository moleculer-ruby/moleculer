require_relative "base"
module Moleculer
  module Node
    ##
    # Represents the local node
    class Local < Base

      def initialize(*args)
        super(*args)

      end

      def local?
        true
      end

    end
  end
end