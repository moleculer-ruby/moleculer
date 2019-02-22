# frozen_string_literal: true

require "forwardable"
require "ostruct"
require "json"

module Moleculer
  module Packets
    # @private
    class Base
      extend Forwardable

      attr_reader :node_id, :broadcast, :namespace, :target

      def self.field(name)
        @fields ||= {}
        @fields[name] = {
          name: name
        }
        define_getter(name)
      end

      def self.define_getter(name)
        class_eval <<-DEFINITION
          def #{name}
            @data[:#{name}] || @data["#{name}"]
          end
        DEFINITION
      end

      class << self
        attr_reader :fields
      end

      def topic
        "MOL.#{name}"
      end

      def self.from(string)
        new JSON.parse(string)
      end

      def initialize(options)
        @data = options.merge(ver: Moleculer::PROTOCOL_VERSION)
      end

      def name
        self.class::NAME
      end

      def serialize
        @data.to_json
      end

      def to_h
        @data
      end
    end
  end
end
