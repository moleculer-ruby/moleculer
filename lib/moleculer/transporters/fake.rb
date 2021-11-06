# frozen_string_literal: true

require_relative "base"

module Moleculer
  module Transporters
    class Fake < Base
      include SemanticLogger::Loggable

      def connect
        @connected = true
        logger.info("connected")
      end
    end
  end
end
