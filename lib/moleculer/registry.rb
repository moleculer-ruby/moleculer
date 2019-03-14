module Moleculer
  ##
  # The Registry manages all ofth
  class Registry
    attr_reader :logger

    def initialize(broker)
      @broker = broker
      @nodes = Moleculer::Support::Hash.new
      @actions = Moleculer::Support::Hash.new
      @events = Moleculer::Support::Hash.new
      @services = Moleculer::Support::Hash.new
      @logger = Moleculer.logger
      @local_node = register_node(Node.new(
                                    local: true,
                                    node_id: Moleculer.node_id,
                                  ))
    end

    ##
    # Registers the node with the registry and updates the action/event handler lists.
    #
    # @param [Moleculer::Node] node the node to register
    def register_node(node)
      logger.info "registering node #{node.id}" unless node.local?
      logger.info "registering LOCAL node '#{node.id}'" if node.local?
      @nodes[node.id] = node
      update_actions(node)
      node
    end

    ##
    # Registers the local service with with the local node, and updates the action/event handler lists
    #
    # @param [Moleculer::Service::Base] service the service to register locally
    def register_local_service(service)
      logger.info "registering LOCAL service '#{service.service_name}'"
      @local_node.register_service(service)
      update_actions(@local_node)
    end

    ##
    # Gets the named action from the registry. If a local action exists it will return the local one instead of a
    # remote action.
    #
    # @param [String] name the name of the action
    #
    # @return [Moleculer::Service::Action|Moleculer::RemoteService::Action]
    def get_action(name)
      local_action = get_local_action(name)

      return local_action if local_action

      action = @actions[name]
      @actions[name].rotate!
      action
    end

    private

    def get_local_action(name)
      @local_node.actions.select { |a| a.name == name.to_s }.first
    end

    def update_actions(node)
      node.actions.each do |action|
        qualified_action_name = "#{action.service.service_name}.#{action.name}"
        @actions[qualified_action_name] ||= []
        @actions[qualified_action_name].reject! { |a| a.id == node.id }
        @actions[qualified_action_name] << node
      end
      logger.debug "registered #{node.actions.length} action(s) for node '#{node.id}'"
    end
  end
end
