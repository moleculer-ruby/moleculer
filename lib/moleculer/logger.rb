# frozen_string_literal: true

module Moleculer
  ##
  # Provides contextual logging functionality.
  module Logger
    ##
    # @private
    class Sublogger
      def initialize(klass)
        @klass  = klass
      end

      def info(*args)
        Console.logger.info(klass, *args)
      end

      def debug(*args)
        Console.logger.debug(klass, *args)
      end

      def error(*args)
        Console.logger.error(klass, *args)
      end

      def warn(*args)
        Console.logger.warn(klass, *args)
      end

      def fatal(*args)
        Console.logger.fatal(klass, *args)
      end

      def self.included(subclass)
        subclass.extend(Console)
      end

      private

      attr_reader :klass, :logger
    end

    def logger
      @logger ||= Sublogger.new(self)
    end
  end
end
