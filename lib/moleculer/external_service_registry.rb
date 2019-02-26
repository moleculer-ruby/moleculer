require "timeout"

require_relative "./node"

module Moleculer
  # The ExternalServiceRegistry represents all of the available Moleculer services on the network. When a call is to be
  # passed to the network the registry is used to group, balance and deliver the request.
  class ExternalServiceRegistry
    attr_reader :nodes

    def initialize(broker)
      @broker = broker
      @nodes = {}
      @actions = {}
      @services = {}
    end

    def get_node_for_action(action_name)
      node_name = @actions[action_name].rotate!.first
      @nodes[node_name]
    end

    def wait_for_service(name, to=5000)
      @broker.logger.info("waiting for service '#{name}'")
        Timeout.timeout(to) do
          sleep 0.01 until @services[name]
        end
      @broker.logger.info("service with '#{name}' registered")
    end

    ##
    # Processes an incoming info packet and updates the registry information
    def process_info_packet(info_packet)
      is_self = info_packet.sender == @broker.node_id
      node = Node.new(info_packet, is_self)
      @nodes[node.name] = node
      node.services.each do |service|
        @services[service.name] ||= []
        next if @services.include?(node.name)
        @services[service.name] << node.name
      end
      node.actions.each do |action|
        @actions[action.name] ||= []
        next if @actions.include?(node.name)
        @actions[action.name] << node.name
      end
    end

  end
end
