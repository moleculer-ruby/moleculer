# frozen_string_literal: true

require "socket"

module Moleculer
  ##
  # The Broker is the main component of Moleculer. It handles services, calls actions, emits events and communicates
  # with remote nodes. You must create a Broker instance on every node.
  #
  # @param namespace [String] namespace of nodes to segment your nodes on the same network
  # @param node_id [String] unique node identifier. Must be unique in a namespace. If not the broker will throw a
  # fatal error and stop the process. Default: hostname + PID
  # @param logger [Logger] logger class. By default, it prints message to the console.
  # @param log_level [Integer] log level for loggers (trace, debug, info, warn, error, fatal)j.
  # @param registry [Hash] settings of Service Registry.
  # @option registry [Class<Moleculer::Registry::Strategies::Base>] strategy: The strategy to use for selecting nodes.
  # @option registry [Hash] strategy_options: Options to pass to the strategy.
  # @param discoverer [Hash] settings of Service Discoverer.
  # @option discoverer [Class<Moleculer::Registry::Discoverers::Base>] discoverer: The discoverer to use for finding
  # nodes.
  # @option discoverer [Hash] discoverer_options: Options to pass to the discoverer.
  class Broker
    include Types
    extend Dry::Initializer

    option :namespace, type: Types::String, optional: true
    option :node_id, type: Types::String, default: proc { "#{Socket.gethostname}-#{Process.pid}" }
    option :logger, type: Types.Instance(Console::Logger), optional: true, default: proc { Console.logger }
    option :log_level, type: Types::Integer, default: proc { ::Logger::INFO }
    option :registry, type: Types::Hash, default: proc { {} }
    option :discoverer, type: Types::Hash, default: proc { {} }

    ##
    # @return [Logger] the logger instance
    attr_reader :logger

    def initialize(**)
      super

      initialize_logger
      initialize_registry(**registry)

      @instance_id = SecureRandom.uuid
      @services = []

      logger.info("Moleculer Ruby v#{Moleculer::VERSION}, Moleculer protocol v#{Moleculer::PROTOCOL_VERSION}")
      logger.info("Namespace: #{namespace || "<not defined>"}")
      logger.info("Node ID: #{@node_id}")
    end

    ##
    # @return [Logger] returns a child logger tagged with the given name
    def get_logger(name)
      Logger.new(logger: logger, subject: self)
    end

    def start
      @start_time = Time.now
    end

    private

    attr_reader :instance_id, :services, :registry, :start_time

    def initialize_registry(**)
      @registry = Registry.new(broker: self, **)
    end

    def initialize_logger
      @logger.level = log_level
      @logger = get_logger("broker")
    end
  end
end
