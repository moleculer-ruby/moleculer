# frozen_string_literal: true

require "socket"
require "securerandom"

require_relative "transit"
require_relative "event_emitter"

module Moleculer
  ##
  # The `Broker` is the main component of Moleculer. It handles services, calls actions,
  # emits events and communicates with remote nodes. You must create a `Broker`
  # instance on every node.
  #
  # @param options [Hash] The Moleculer broker options.
  # @option options [String] :nodeID The node ID, defaults to the hostname + pid.
  # @option options [String] :namespace The Moleculer namespace, defaults to blank.
  # @option options [String | Hash] :logger The logger options, defaults to `$stdout`.
  # @option options [String] :transporter The transporter options, defaults to `"fake"`.
  class Broker
    ##
    # @private
    class Options
      attr_reader :namespace, :node_id, :transporter

      def initialize(opts = {})
        @namespace   = opts[:namespace] || ""
        @node_id     = opts[:node_id] || "#{Socket.gethostname}-#{Process.pid}}"
        @logger      = opts[:logger] || $stdout
        @transporter = opts[:transporter] || "fake"
      end

      def logger
        case @logger
        when $stdout
          { io: $stdout, formatter: :color }
        when String
          { file_name: @logger }
        when Hash
          hash
        end
      end
    end

    include SemanticLogger::Loggable

    ##
    # @return [Boolean] `true` if the broker is started, `false` otherwise.
    attr_reader :started

    ##
    # @return [String] the instance uuid
    attr_reader :instance_id

    def initialize(opts = {})
      @options     = Options.new(opts)
      @started     = false
      @instance_id = SecureRandom.uuid
      @local_bus   = EventEmitter.new
      @transit     = Transit.new(self, Transporters.get(options.transporter).new)

      set_semantic_logger(options.logger)
    end

    def start
      logger.info("Moleculer Ruby v#{Moleculer::VERSION}")
      logger.info("starting")
      transit.connect
    end

    private

    attr_reader :options, :local_bus, :transit

    def set_semantic_logger(logger)
      SemanticLogger.add_appender(**logger)
    end
  end
end
