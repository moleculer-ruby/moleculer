# frozen_string_literal: true

require_relative "../serializers"

module Moleculer
  module Broker
    ##
    # Packet serialization configuration
    module Serializer
      attr_reader :serializer
      def initialize(*)
        @serializer = resolve_serializer(@options[:serializer])
        super
      end

      private

      def resolve_serializer(serializer)
        Serializers.resolve(serializer).new(self)
      end
    end
  end
end
