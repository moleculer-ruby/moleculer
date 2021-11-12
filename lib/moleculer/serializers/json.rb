# frozen_string_literal: true

require_relative "base"

module Moleculer
  module Serializers
    ##
    # JSON serializer
    class JSON < Base
      def serialize(packet)
        packet
          .to_h
          .to_camelback_keys
      end

      def deserialize(data)
        ::JSON.parse(data).to_snake_keys
      end
    end
  end
end
