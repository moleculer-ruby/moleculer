require "json"

module Moleculer
  module Serializers
    class Json

      def initialize
        @logger = Moleculer.logger
      end

      def serialize(message)
        message.to_json
      end

      def deserialize(message)
        begin
          Support::Hash.from_hash(JSON.parse(message))
        rescue => e
          @logger.error e
        end
      end
    end
  end
end