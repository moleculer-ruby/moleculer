# frozen_string_literal: true

module Moleculer
  module Catalogs
    class Base
      def initialize
        @items = {}
      end

      def add(id, item)
        items[id] = item
      end

      def get(id)
        items[id]
      end

      def has?(id)
        items.key?(id)
      end

      def count
        items.count
      end

      def delete(id)
        items.delete(id)
      end

      def list
        items.values
      end

      private

      attr_reader :items
    end
  end
end
