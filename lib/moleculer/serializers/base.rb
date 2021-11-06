# frozen_string_literal: true

module Moleculer
  module Serializers
    ##
    # Base serializer class
    class Base
      def serialize(data, type)
        raise NotImplementedError
      end

      def deserialize(data, type)
        raise NotImplementedError
      end
    end
  end
end
