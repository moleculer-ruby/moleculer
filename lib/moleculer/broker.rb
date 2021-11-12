# frozen_string_literal: true

require "socket"
require "securerandom"

require_relative "transit"
require_relative "event_emitter"
require_relative "registry"

module Moleculer
  ##
  # The `Broker` is the main component of Moleculer. It handles services, calls actions,
  # emits events and communicates with remote nodes. You must create a `Broker`
  # instance on every node.
  class Broker
    include SemanticLogger::Loggable

    ##
    # @return [Boolean] `true` if the broker is started, `false` otherwise.
    attr_reader :started

    ##
    # @return [String] the instance uuid
    attr_reader :instance_id

    ##
    # @param opts [Hash] The Moleculer broker options.
    # @option opts [String] :nodeID The node ID, defaults to the hostname + pid.
    # @option opts [String] :namespace The Moleculer namespace, defaults to blank.
    # @option opts [String | Hash] :logger The logger options, defaults to `$stdout`.
    # @option opts [String] :transporter The transporter options, defaults to `"fake"`.
    # @option opts [String] :services The services to register, defaults to `[]`.
    def initialize(opts = {})
      @started     = false
      @node_id     = opts[:node_id] || "#{Socket.gethostname}-#{Process.pid}}"
      @instance_id = SecureRandom.uuid
      @local_bus   = EventEmitter.new
      @local_node  = Node.new(
        id:       @node_id,
        services: (opts[:services] || []),
        local:    true,
      )
      @registry    = Registry.new(self, local_node)

      set_semantic_logger(opts[:logger] || $stdout)
    end

    ##
    # Starts the broker.
    def start
      logger.info("Moleculer Ruby v#{Moleculer::VERSION}")
      logger.info("starting")
    end

    ##
    # Calls a service action.
    #
    # @param [String] endpoint The endpoint of the service.
    # @param [Hash] params The params to pass to the action
    #
    # @return [any] the result of the action.
    def call(endpoint, params = {})
      logger.info("calling '#{endpoint}'", params)

      registry.call(endpoint, create_context(params))
    end

    private

    attr_reader :options, :local_bus, :transit, :local_node, :registry

    def create_context(params)
      Context.new(self, params)
    end

    # rubocop:disable Naming/AccessorMethodName
    def set_semantic_logger(logger)
      SemanticLogger.add_appender(**log_options(logger))
    end
    # rubocop:enable Naming/AccessorMethodName

    def log_options(logger)
      case logger
      when $stdout
        { io: $stdout, formatter: :color }
      when String
        { file_name: logger }
      when Hash
        hash
      end
    end
  end
end
