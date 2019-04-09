require "ap"

module Moleculer
  module Support
    ##
    # LogProxy acts as a bridge between multiple logger types.
    # @private
    class LogProxy
      def initialize(logger, prefix = "")
        @logger = logger
        @prefix = prefix
      end

      ##
      # @return [Moleculer::LogProxy] a prefixed child of the log proxy
      def get_child(prefix)
        self.class.new(@logger, prefix)
      end

      def fatal(*args)
        @logger.fatal(parse_args(args.unshift(@prefix))) if @logger
      end

      def error(*args)
        @logger.error(parse_args(args.unshift(@prefix))) if @logger
      end

      def warn(*args)
        @logger.warn(parse_args(args.unshift(@prefix))) if @logger
      end

      def info(*args)
        @logger.info(parse_args(args.unshift(@prefix))) if @logger
      end

      def debug(*args)
        @logger.debug(parse_args(args.unshift(@prefix))) if @logger
      end

      def trace(*args)
        return unless @logger

        return @logger.trace(parse_args(args.unshift(@prefix))) if @logger.respond_to?(:trace)

        @logger.debug(parse_args(args.unshift(@prefix)))
      end

      def level
        @logger.level
      end

      private

      def parse_args(args)
        if args.last.is_a?(Hash)
          args.each_index do |v|
            args[v] = "\n" + args[v].ai + "\n" unless args[v].is_a?(String)
          end
        end

        args.join(" ").strip
      end
    end
  end
end
