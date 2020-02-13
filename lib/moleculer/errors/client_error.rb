# frozen_string_literal: true

require_relative "error"

module Moleculer
  module Errors
    class ClientError < Error
      def initialize(message, code, type, data)
        super(message, code || 400, type, data)
      end
    end
  end
end
