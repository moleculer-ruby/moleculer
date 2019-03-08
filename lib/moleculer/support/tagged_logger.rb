module Moleculer
  module Support
    class TaggedLogger
      attr_reader :logger
      include Logger::Severity

      def initialize(logger, tag)
        @logger = logger
        @tag = "MOL.#{tag}"
      end

      def add(level, message)
        @logger.add(level, message, @tag)
      end

      def info(message)
        add(INFO, message)
      end

      def warn(message)
        add(WARN, message)
      end

      def debug(message)
        add(DEBUG, message)
      end

      def error(message)
        add(ERROR, message)
      end

      def fatal(message)
        add(FATAL, message)
      end

      def unknown(message)
        add(UNKNOWN, message)
      end
    end
  end
end
