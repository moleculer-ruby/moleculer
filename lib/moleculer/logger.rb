module Moleculer
  ##
  # Moleculer built in tagged logger.
  # @param [Console] logger The broker logger instance
  class Logger
    extend Dry::Initializer

    option :logger, type: Types.Instance(Console::Logger)
    option :subject

    def info(*)
      logger.info(subject, *)
    end

    def debug(*)
      logger.debug(subject, *)
    end

    def warn(*)
      logger.warn(subject, *)
    end

    def error(*)
      logger.error(subject, *)
    end
  end
end