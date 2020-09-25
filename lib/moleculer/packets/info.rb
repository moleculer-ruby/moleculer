# frozen_string_literal: true

require_relative "base"

module Moleculer
  module Packets
    ##
    # Info packet
    class Info < Base
      self.type = "INFO"

      ##
      # @param [String] target
      def initialize(target)
        super
        @target = target
      end
    end
  end
end
