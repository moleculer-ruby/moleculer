# frozen_string_literal: true

module Moleculer
  module Logging
    ##
    # Ties into the Async#logger providing a subject for logging messages
    class Logger
      def initialize(subject)
        @subject = subject
      end

      def info(message)
        base.info(subject) { message }
      end

      def warn(message)
        base.warn(subject) { message }
      end

      def error(message)
        base.error(subject) { message }
      end

      def fatal(message)
        base.fatal(subject) { message }
      end

      def debug(message)
        base.debug(subject) { message }
      end

      private

      attr_reader :subject

      def base
        Async.logger
      end
    end
  end
end
