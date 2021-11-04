# frozen_string_literal: true

require "socket"

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
      def initialize(opts = {})
        @namespace = opts[:namespace] || ""
        @node_id   = opts[:node_id] || "#{Socket.gethostname}-#{Process.pid}}"
      end

      private

      attr_accessor :namespace, :node_id
    end

    ##
    # @return [Boolean] `true` if the broker is started, `false` otherwise.
    attr_reader :started

    def initialize(options = {})
      @options = Options.new(options)
      @started = false
    end

    private

    attr_reader :options
  end
end
