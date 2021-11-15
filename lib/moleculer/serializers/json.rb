# frozen_string_literal: true

require_relative "base"

module Moleculer
  module Serializers
    ##
    # JSON serializer
    class JSON < Base
      def serialize(packet)
        packet.to_h.deep_camelize_keys.to_json
      end

      def deserialize(data)
        ::JSON.parse(data).deep_underscore_keys
      end
    end
  end
end
