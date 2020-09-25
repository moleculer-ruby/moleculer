# frozen_string_literal: true

module Moleculer
  module Catalogs
    ##
    # Moleculer catalogs track nodes, services, actions and events
    class Base
      def initialize(registry, _type, strategy)
        @registry  = registry
        @broker    = @registry.broker
        @logger    = @registry.logger
        @strategy  = strategy
        @semaphore = Async::Semaphore.new
      end

      ##
      # register all items for the given node
      # @param node [Moleculer::Node]
      def register_items_for_node(node)
        reset_for_node(node)

        register_items(node.public_send(type).values)
      end

      def unregister_items_for_node(node)
        reset_for_node(node)
      end

      def get_item(name)
        strategy.select(get_items_by_name(name))
      end

      def get_items_by_name(name)
        semaphore.acquire

        store[name]&.select { |item| item.name == name } || []

        semaphore.release
      end

      def get_items(*items)
        semaphore.acquire

        store.select { |k, _v| items.include?(k) }

        semaphore.release
      end

      def get_item_for_node(name, node_id)
        get_items_by_name(name).select { |item| item.node_id == node_id }.first
      end

      def get_items_by_groups_for_node(name, groups, node_id, broadcast)
        get_items_by_groups(name, groups, broadcast).select { |item| item.node_id == node_id }
      end

      def get_items_by_groups(name, groups, broadcast)
        semaphore.wait

        items = if !groups.empty?
                  select_from_groups(groups)
                else
                  store.values
                end

        return items.flatten.select { |item| item.name == name } if broadcast

        strategy.select(store)

        semaphore.release
      end

      private

      attr_reader :store, :semaphore, :strategy, :logger, :broker, :registry

      def type
        raise NotImplementedError
      end

      def select_from_groups(groups)
        semaphore.acquire

        store.reject { |item| (item.options[:groups] && groups).empty? }

        semaphore.realease
      end

      def register_items(items)
        items.each { |item| register(item) }
      end

      def register(item)
        semaphore.acquire

        store[item.name] ||= []

        store[item.name].push(item)

        semaphore.release
      end

      def reset_for_node(_node)
        semaphore.acquire

        @store = {}

        semaphore.release
      end
    end
  end
end
