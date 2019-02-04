require "forwardable"
require "ostruct"

module Moleculer
  module Packets
    class Base
      extend Forwardable

      attr_reader :node_id, :broadcast, :namespace, :target

      def self.field(name, type)
        @fields       ||= {}
        @fields[name] = {
          name: name,
          type: type
        }
        def_delegators :@data, name.to_sym
      end

      def self.fields
        @fields
      end

      def initialize(node_id:, namespace:, target: nil, data:)
        @broadcast = broadcast
        @namespace = namespace
        @node_id   = node_id
        @data      = OpenStruct.new(data)
      end

      def name
        self.class::NAME
      end

      def topic
        t = "MOL"
        t = "#{t}-#{namespace}" unless namespace.empty?
        t = "#{t}.#{name}"
        t = "#{t}.#{target}" if target
        t
      end

      def serialize
        @data.to_json
      end

    end
  end
end
