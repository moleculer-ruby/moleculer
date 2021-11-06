# frozen_string_literal: true

require_relative "base"

module Moleculer
  module Serializers
    ##
    # JSON serializer
    class JSON < Base
      def serialize(data)
        data.to_json
      end

      def deserialize(data)
        ::JSON.parse(data)
      end
    end
  end
end
