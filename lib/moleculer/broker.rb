require "concurrent-edge"
require "socket"
require "uri"

require_relative "./packets"
require_relative "./transporters"
require_relative "./version"

module Moleculer
  # The Broker is the main component of Moleculer. It handles services, calls actions, emits events and
  # communicates with remote nodes.
  class Broker < Concurrent::Actor::AbstractContext
    PROTOCOL_VERSION = "3"

    attr_reader :node_id, :transporter, :logger, :namespace

    # @param transporter [String] transporter settings
    # @param namespace [String] Namespace of nodes to segment your nodes on the same network.
    # @param node_id [String] Unique node identifier. Must be unique in a namespace.
    def initialize(
      node_id: "#{Socket.gethostname.downcase}-#{Process.pid}",
      transporter: "redis://localhost",
      namespace: ""
    )
      @namespace   = namespace
      @logger      = Logger.new(STDOUT)
      @node_id     = node_id
      @transporter = Transporters.for(transporter).new(broker: self, uri: transporter)
    end

    def start
      @logger.info "Moleculer Ruby #{Moleculer::VERSION}"
      @logger.info "Node ID: #{node_id}"
      @logger.info "Transporter: #{transporter.name}"
      transporter.connect
      broadcast_discover
    end

    private

    def broadcast_discover
      @logger.info "Send #{Packets::Discover::NAME} to '<all nodes>'"
      transporter.broadcast(Packets::Discover.new(node_id: node_id, namespace: namespace, data: {
        ver:    PROTOCOL_VERSION,
        sender: node_id
      }))
    end

  end
end



