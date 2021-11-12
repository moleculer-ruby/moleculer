# frozen_string_literal: true

require_relative "base"

module Moleculer
  module Node
    ##
    # @private
    class Local < Base
      def initialize(options = {})
        super(options.merge(local: true))
      end
    end
  end
end
