# frozen_string_literal: true

module Moleculer
  ##
  # Call and event context
  class Context
    attr_reader :params

    def initialize(broker, params = {}, options = {})
      @broker  = broker
      @params  = params
      @options = options
    end
  end
end
