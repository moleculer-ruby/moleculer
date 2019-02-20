require_relative "./node"

module Moleculer
  # The ExternalServiceRegistry represents all of the available Moleculer services on the network. When a call is to be
  # passed to the network the registry is used to group, balance and deliver the request.
  class ExternalServiceRegistry
    attr_reader :nodes

    def initialize(broker)
      @broker = broker
      @nodes = {}
    end

    ##
    # Processes an incoming info packet and updates the registry information
    def process_info_packet(info_packet)
      is_self = info_packet.sender == @broker.node_id
      unless @nodes[info_packet.sender]
        @broker.logger.debug "registering node '#{info_packet.sender}'"
        @nodes[info_packet.sender] = Node.new(info_packet, is_self)
      end

    end

  end
end
