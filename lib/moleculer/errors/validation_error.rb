# frozen_string_literal: true

require_relative "client_error"
module Moleculer
  module Errors
    class ValidationError < ClientError
      def initialize(message, type, data)
        super(message, 422, type, data)
      end
    end
  end
end
