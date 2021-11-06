# frozen_string_literal: true

require "socket"
require "securerandom"

module Moleculer
  ##
  # The `Broker` is the main component of Moleculer. It handles services, calls actions,
  # emits events and communicates with remote nodes. You must create a `Broker`
  # instance on every node.
  #
  # @param options [Hash] The Moleculer broker options.
  # @option options [String] :nodeID The node ID, defaults to the hostname + pid.
  # @option options [String] :namespace The Moleculer namespace, defaults to blank.
  class Broker
    ##
    # @private
    class Options
      attr_reader :namespace, :node_id

      def initialize(opts = {})
        @namespace   = opts[:namespace] || ""
        @node_id     = opts[:node_id] || "#{Socket.gethostname}-#{Process.pid}}"
      end
    end

    ##
    # @return [Boolean] `true` if the broker is started, `false` otherwise.
    attr_reader :started

    ##
    # @return [String] the instance uuid
    attr_reader :instance_id

    def initialize(options = {})
      @options     = Options.new(options)
      @started     = false
      @instance_id = SecureRandom.uuid
      @local_bus   = EventEmitter.new
    end

    private

    attr_reader :options, :local_bus
  end
end
