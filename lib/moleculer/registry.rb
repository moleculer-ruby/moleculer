require_relative "errors/local_node_already_registered"
require_relative "errors/action_not_found"
require_relative "support"

module Moleculer
  ##
  # The Registry manages the available services on the network
  class Registry
    include Support

    attr_reader :local_node

    ##
    # @param [Moleculer::Broker] broker the service broker instance
    def initialize(broker)
      @broker   = broker
      @nodes    = Concurrent::Hash.new
      @actions  = Concurrent::Hash.new
      @events   = Concurrent::Hash.new
      @services = Concurrent::Hash.new
      @logger   = Moleculer.logger
    end

    ##
    # Registers the node with the registry and updates the action/event handler lists.
    #
    # @param [Moleculer::Node] node the node to register
    #
    # @return [Moleculer::Node] the node that has been registered
    def register_node(node)
      return local_node if @local_node && node.id == @local_node.id

      if node.local?
        raise Errors::LocalNodeAlreadyRegistered, "A LOCAL node has already been registered" if @local_node

        @logger.info "registering LOCAL node '#{node.id}'"
        @local_node = node
      end
      @logger.info "registering node #{node.id}" unless node.local?
      @nodes[node.id] = { node: node }
      update_node_for_load_balancer(node)
      update_services(node)
      update_actions(node)
      node
    end

    ##
    # Gets the named action from the registry. If a local action exists it will return the local one instead of a
    # remote action.
    #
    # @param action_name [String] the name of the action
    #
    # @return [Moleculer::Service::Action|Moleculer::RemoteService::Action]
    def fetch_action(action_name)
      node = fetch_next_node_for_action(action_name)
      fetch_action_from_node(action_name, node)
    end

    ##
    # Gets the named action from the registry for the given node. Raises an error if the node does not exist or the node
    # does not have the specified action.
    #
    # @param action_name [String] the name of the action
    # @param node_id [String] the id of the node from which to get the action
    #
    # @return [Moleculer::Service::Action] the action from the specified node_id
    # @raise [Moleculer::NodeNotFound] raised when the specified node_id was not found
    # @raise [Moleculer::ActionNotFound] raised when the specified action was not found on the specified node
    def fetch_action_for_node_id(action_name, node_id)
      node = fetch_node(node_id)
      fetch_action_from_node(action_name, node)
    end

    def has_services(*services)
      services - @services.values == []
    end

    private

    def get_local_action(name)
      @local_node.actions.select { |a| a.name == name.to_s }.first
    end

    def update_node_for_load_balancer(node)
      @nodes[node.id][:last_called_at] = Time.now
    end

    def fetch_action_from_node(action_name, node)
      node.actions.fetch(action_name)
    rescue KeyError
      raise(Errors::ActionNotFound, "The action '#{action_name}' was found on the node with id '#{node.id}'")
    end

    def fetch_next_node_for_action(action_name)
      fetch_node_list_for(action_name).min_by { |a| a[:last_called_at] }[:node]
    end

    def fetch_node(node_id)
      @nodes.fetch(node_id)[:node]
    rescue KeyError
      raise Errors::NodeNotFound, "The node with the id '#{node_id}' was not found."
    end

    def fetch_node_list_for(action_name)
      node_list = HashUtil.fetch(@actions, action_name)
      node_list.collect { |name| @nodes[name] }
    rescue KeyError
      raise Errors::ActionNotFound, "The action '#{action_name}' was not found"
    end

    def update_actions(node)
      node.actions.values.each do |action|
        replace_action(action, node)
      end
      @logger.debug "registered #{node.actions.length} action(s) for node '#{node.id}'"
    end

    def update_services(node)
      node.services.values.each do |service|
        replace_service(service, node)
      end
    end

    def replace_service(service, node)
      @services[service.service_name] ||= []
      nodes                             = @services[service.service_name].reject! { |a| a.id == node.id }
      @logger.info "registered new service '#{service.service_name}'" unless nodes
      @services[service.service_name] << node.id
    end

    def replace_action(action, node)
      @actions[action.name] ||= []
      @actions[action.name].reject! { |a| a == node.id }
      @actions[action.name] << node.id
    end
  end
end
