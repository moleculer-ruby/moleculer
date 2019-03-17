require_relative "errors/local_node_already_registered"

module Moleculer
  ##
  # The Registry manages the available services on the network
  class Registry
    ##
    # @param [Moleculer::Broker] broker the service broker instance
    def initialize(broker)
      @broker   = broker
      @nodes    = {}
      @actions  = Hash.new([])
      @events   = {}
      @services = {}
      @logger   = Moleculer.logger
    end

    ##
    # Registers the node with the registry and updates the action/event handler lists.
    #
    # @param [Moleculer::Node] node the node to register
    #
    # @return [Moleculer::Node] the node that has been registered
    def register_node(node)
      if node.local?
        raise Errors::LocalNodeAlreadyRegistered, "A LOCAL node has already been registered" if @local_node

        @logger.info "registering LOCAL node '#{node.id}'"
        @local_node = node
      end
      logger.info "registering node #{node.id}" unless node.local?
      @nodes[node.id] = node
      update_actions(node)
      node
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
        replace_action(qualified_action_name, node)
      end
      logger.debug "registered #{node.actions.length} action(s) for node '#{node.id}'"
    end

    def replace_action(action, node)
      @actions[action].reject! { |a| a.id == node.id }
      @actions[action] << node
    end
  end
end
