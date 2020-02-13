# frozen_string_literal: true

module Moleculer
  module Registry
    ##
    # Moleculer catalogs track nodes, services, actions and events
    class ItemCatalog
      def initialize(registry, type, strategy)
        @registry = registry
        @broker   = @registry.broker
        @logger   = @registry.logger
        @store    = Concurrent::Hash.new
        @strategy = strategy
        @type     = type
      end

      ##
      # register all items for the given node
      #
      # @param node [Moleculer::Node]
      def register_items_for_node(node)
        reset_for_node(node)
        register_items(node.public_send(@type).values)
      end

      def unregister_items_for_node(node)
        reset_for_node(node)
      end

      def get_item(name)
        @strategy.select(get_items(name))
      end

      def get_items(name)
        @store[name]&.select { |item| item.name == name } || []
      end

      def get_item_for_node(name, node_id)
        get_items(name).select { |item| item.node_id == node_id }.first
      end

      def get_items_by_groups_for_node(name, groups, node_id, broadcast)
        get_items_by_groups(name, groups, broadcast).select { |item| item.node_id == node_id }
      end

      def get_items_by_groups(name, groups, broadcast)
        items = if !groups.empty?
                  select_from_groups(groups)
                else
                  @store.values
                end
        return items.flatten.select { |item| item.name == name } if broadcast

        @strategy.select(@store)
      end

      private

      def select_from_groups(groups)
        @store.reject { |item| (item.options[:groups] && groups).empty? }
      end

      def register_items(items)
        items.each { |item| register(item) }
      end

      def register(item)
        @store[item.name] ||= []
        @store[item.name].push(item)
      end

      def reset_for_node(node)
        @store = Concurrent::Hash[@store.map do |name, items|
          [name, items.reject { |i| i.node_id == node.id }]
        end]
      end
    end
  end
end
