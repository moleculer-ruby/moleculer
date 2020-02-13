# frozen_string_literal: true

require_relative "../node"
require_relative "node_catalog"
require_relative "item_catalog"

module Moleculer
  module Registry
    ##
    # Node registry
    class Base
      attr_reader :broker, :logger

      ##
      # @param broker [Moleculer::Broker] the moleculer service broker
      def initialize(broker, options)
        @broker          = broker
        @logger          = @broker.get_logger("registry")
        @options         = options
        @event_catalog   = ItemCatalog.new(self, :events, @options[:strategy].new)
        @action_catalog  = ItemCatalog.new(self, :actions, @options[:strategy].new)
        @service_catalog = ItemCatalog.new(self, :services, @options[:strategy].new)
        @node_catalog    = NodeCatalog.new(self)
        register_node(create_local_node)
      end

      def process_node_info(packet)
        return if packet.payload[:sender] == @broker.node_id

        register_node(Node.from_info_packet(broker, packet))
      end

      def process_heartbeat(packet)
        node = @node_catalog.get(packet.payload[:sender])
        node&.beat
      end

      ##
      # Registers all associated services for the given node.
      #
      # @param node [Moleculer::Node] the node to register
      def register_node(node)
        @node_catalog.add(node)
        @service_catalog.register_items_for_node(node)
        @action_catalog.register_items_for_node(node)
        @event_catalog.register_items_for_node(node)
      end

      def unregister_services_for_node(node)
        @service_catalog.unregister_items_for_node(node)
        @action_catalog.unregister_items_for_node(node)
        @event_catalog.unregister_items_for_node(node)
      end

      def get_event_endpoints(name, groups, broadcast = true)
        @event_catalog.get_items_by_groups(name, groups, broadcast)
      end

      def get_local_event_endpoints(name, groups, broadcast)
        @event_catalog.get_items_by_groups_for_node(name, groups, @node_id, broadcast)
      end

      ##
      # @return [Moleculer::Node] the local moleculer node
      def local_node
        @node_catalog.local_node
      end

      private

      def create_local_node
        Node.new(@broker,
                 id:       @broker.node_id,
                 local:    true,
                 ip_list:  Utils.get_ip_list,
                 seq:      1,
                 client:   {
                   type:         "ruby",
                   version:      Moleculer::VERSION,
                   lang_version: RUBY_VERSION,
                 },
                 services: @broker.services)
      end
    end
  end
end
