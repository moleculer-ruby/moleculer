# frozen_string_literal: true

module Moleculer
  module Serializers
    ##
    # Base class for all serializers.
    class Base
      extend Dry::Initializer

      option :broker, type: Types.Instance(Broker)

      ##
      # @param [Object] object The object to serialize
      # @option [Symbol|String] type The type of packet
      def serialize(object:, type:)
        raise NotImplementedError
      end

      ##
      # @param [String] data The data to deserialize
      # @option [Symbol|String] type The type of packet
      def deserialize(data:, type:)
        raise NotImplementedError
      end
    end
  end
end
