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
        @fields       ||= {}
        @fields[name] = {
          name: name
        }
        define_getter(name)
      end

      def self.define_getter(name)
        self.class_eval <<-DEFINITION
          def #{name}
            @data[:#{name}]
          end
        DEFINITION
      end

      def self.fields
        @fields
      end

      def topic
        "MOL.#{name}"
      end

      def self.from(string)
        new JSON.parse(string)
      end

      def initialize(options)
        @data = HashWithIndifferentAccess.new(options.merge(ver: Moleculer::PROTOCOL_VERSION))
      end

      def name
        self.class::NAME
      end

      def serialize
        JSON.dump(@data.to_h)
      end

      def to_h
        HashWithIndifferentAccess.new(@data)
      end

    end
  end
end
