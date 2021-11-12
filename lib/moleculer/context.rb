# frozen_string_literal: true

module Moleculer
  ##
  # Call and event context
  class Context
    attr_reader :params, :broker

    def initialize(broker, params = {})
      @broker  = broker
      @params  = params
    end
  end
end
