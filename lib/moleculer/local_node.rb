# frozen_string_literal: true

module Moleculer
  ##
  # @private
  class LocalNode < Node
    def initialize(options = {})
      super(options.merge(local: true))
    end
  end
end
