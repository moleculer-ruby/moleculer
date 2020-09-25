# frozen_string_literal: true

require_relative "logging/logger"

module Moleculer
  ##
  # Included to add logging functionality to a class
  module Logging
    private

    def logger
      @logger ||= Logger.new(self)
    end
  end
end
