# frozen_string_literal: true

module Moleculer
  module Serializers
    ##
    # JSON serializer for Moleculer
    class JSON < Base
      def serialize(object:, type: nil)
        ::JSON.dump(object)
      end

      def deserialize(data:, type: nil)
        ::JSON.parse(data)
      end
    end
  end
end
