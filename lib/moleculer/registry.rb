module Moleculer
  class Registry
    attr_reader :local_node, :logger

    def initialize(broker)
      @broker = broker
      @nodes = Moleculer::Support::Hash.new
      @actions = Moleculer::Support::Hash.new
      @events = Moleculer::Support::Hash.new
      @logger = Moleculer.create_logger("BROKER.REGISTRY")
      @local_node = register_node(Node.new(
                                    local: true,
                                    node_id: Moleculer.node_id,
                                    register_service_callback: ->(_service, node) { update_actions(node) },
                                  ))
    end

    def register_node(node)
      logger.info "registering node #{node.id}" unless node.local?
      logger.info "registering LOCAL node #{node.id}" if node.local?
      @nodes[node.id] = node
      update_actions(node)
      node
    end

    def register_local_service(service)
      @local_node.register_service(service)
    end

    def update_actions(node)
      node.actions.each do |action|
        @actions[action].reject! { |a| a.id == node.id }
        @actions[action] << node
      end
    end
  end
end
