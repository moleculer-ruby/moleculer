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
        def_delegators :@data, name.to_sym
      end

      def self.fields
        @fields
      end

      def topic
        "MOL.#{name}"
      end

      def from(string)
        new JSON.parse(string)
      end

      def initialize(options)
        @data = OpenStruct.new(options.merge(ver: Moleculer::PROTOCOL_VERSION))
      end

      def name
        self.class::NAME
      end

      def serialize
        JSON.dump(@data.to_h)
      end

    end
  end
end
