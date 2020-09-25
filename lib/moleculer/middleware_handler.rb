# frozen_string_literal: true

module Moleculer
  class MiddlewareHandler
    include Logging

    def initialize(broker)
      @borker = broker
    end

    def add(middleware); end
  end
end
