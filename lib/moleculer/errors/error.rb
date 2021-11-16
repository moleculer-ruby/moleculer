# frozen_string_literal: true

module Moleculer
  ##
  # Parent class for all Moleculer errors
  class Error < StandardError
    attr_reader :code, :message, :data, :tyoe, :retryable

    def initialize(message, code, type, data = nil)
      super(message)
      @code      = code
      @message   = message
      @data      = data
      @type      = type
      @retryable = false
    end
  end
end
