# frozen_string_literal: true

require_relative "errors/protocol_mismatch_error"
require_relative "errors/request_rejected_error"
require_relative "errors/request_timeout_error"
require_relative "errors/service_not_found_error"
require_relative "errors/validation_error"

module Moleculer
  module Errors
    def self.recreate_error(error)
      case error[:name]
      when "ValidationError"
        return ValidationError.new(error[:message], error[:type], error)
      end
    end
  end
end
