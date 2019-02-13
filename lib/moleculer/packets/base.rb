# frozen_string_literal: true

require "forwardable"
require "ostruct"

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

      def from(string)
        new JSON.parse(string)
      end

      def initialize(options)
        @data = OpenStruct.new(options)
      end

      def name
        self.class::NAME
      end

      def serialize
        @data.to_json
      end

    end
  end
end
