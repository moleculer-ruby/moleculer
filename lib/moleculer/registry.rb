require_relative "errors/local_node_already_registered"
require_relative "errors/action_not_found"
require_relative "errors/node_not_found"
require_relative "support"

module Moleculer
  ##
  # The Registry manages the available services on the network
  class Registry
    ##
    # @private
    class ActionList
      ##
      # @private
      class ActionListItem
        def initialize(name)
          @action_name = name
          @nodes       = Concurrent::Hash.new
        end

        def add_node(node)
          @nodes[node.id] = { node: node, last_requested_at: Time.now }
        end

        def remove_node(node_id)
          @nodes.delete(node_id)
        end

        def select_action
          select_node.actions[@action_name]
        end

        private

        def select_node
          node                                = @nodes.values.min_by { |a| a[:last_requested_at] }[:node]
          @nodes[node.id][:last_requested_at] = Time.now
          node
        end
      end

      def initialize
        @actions = Concurrent::Hash.new
      end

      def add(action)
        name             = action.name
        @actions[name] ||= ActionListItem.new(name)
        @actions[name].add_node(action.node)
      end

      def remove(action); end

      def select_action(action_name)
        unless @actions[action_name]
          raise Errors::ActionNotFound, "The action '#{action_name}' was not found on the node with id '#{node.id}'"
        end

        @actions[action_name].select_action
      end
    end

    include Support

    attr_reader :local_node

    ##
    # @param [Moleculer::Broker] broker the service broker instance
    def initialize(broker)
      @broker   = broker
      @nodes    = Concurrent::Hash.new
      @actions  = ActionList.new
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
      update_events(node)
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
      @actions.select_action(action_name)
    end

    def fetch_events(event_name)
      nodes = fetch_next_nodes_for_event(event_name)
      nodes.map { |node| fetch_event_from_node(event_name, node) }
    end

    def fetch_events_for_node_id(event_name, node_id)
      node = @nodes.fetch(node_id)[:node]
      node.services.values.map { |s| s.events.values }.flatten.select { |e| e.name == event_name }
    end

    def fetch_node(node_id)
      @nodes.fetch(node_id)[:node]
    rescue KeyError
      raise Errors::NodeNotFound, "The node with the id '#{node_id}' was not found."
    end

    def safe_fetch_node(node_id)
      fetch_node(node_id)
    rescue Errors::NodeNotFound
      nil
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

    def missing_services(*services)
      services - @services.keys
    end

    def remove_node(node_id)
      @logger.info "removing node '#{node_id}'"
      @nodes.delete(node_id)
      remove_node_from_actions(node_id)
      remove_node_from_events(node_id)
    end

    private

    def get_local_action(name)
      @local_node.actions.select { |a| a.name == name.to_s }.first
    end

    def update_node_for_load_balancer(node)
      @nodes[node.id][:last_called_at] = Time.now
    end

    def fetch_event_from_node(event_name, node)
      node.events.fetch(event_name)
    rescue KeyError
      raise Errors::EventNotFound, "The event '#{event_name}' was not found on the node id with id '#{node.id}'"
    end

    def fetch_next_nodes_for_event(event_name)
      service_names = HashUtil.fetch(@events, event_name, {}).keys
      node_names    = service_names.map { |s| @services[s] }
      nodes         = node_names.map { |names| names.map { |name| @nodes[name] } }
      nodes.map { |node_list| node_list.min_by { |a| a[:last_called_at] }[:node] }
    end

    def remove_node_from_actions(node_id)
      @actions.values.each do |action|
        action.reject! { |id| id == node_id }
      end
    end

    def remove_node_from_events(node_id)
      @events.values.each do |event|
        event.values.each do |list|
          list.reject! { |id| id == node_id }
        end
      end
    end

    def update_actions(node)
      node.actions.values.each do |action|
        @actions.add(action)
      end
      @logger.debug "registered #{node.actions.length} action(s) for node '#{node.id}'"
    end

    def update_events(node)
      node.services.values.each do |service|
        service.events.values.each do |event|
          replace_event(event, service, node)
        end
      end
      @logger.debug "registered #{node.events.length} event(s) for node '#{node.id}'"
    end

    def update_services(node)
      node.services.values.each do |service|
        replace_service(service, node)
      end
    end

    def replace_service(service, node)
      @services[service.service_name] ||= []
      nodes                             = @services[service.service_name].reject! { |a| a == node.id }
      @logger.info "registered new service '#{service.service_name}'" unless nodes
      @services[service.service_name] << node.id
    end

    def replace_event(event, service, node) # rubocop:disable Metric/AbcSize
      @events[event.name]                       ||= Concurrent::Hash.new
      @events[event.name][service.service_name] ||= Concurrent::Array.new
      @events[event.name][service.service_name] << node.id unless @events[event.name][service.service_name].include?(node.id)
    end
  end
end
