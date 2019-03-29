require "json"

module Moleculer
  module Serializers
    ##
    # Serializes data packets to and from JSON
    class Json
      def initialize
        @logger = Moleculer.logger
      end

      def serialize(message)
        message.as_json.to_json
      end

      def deserialize(message)
        JSON.parse(message)
      rescue StandardError => e
        @logger.error e
      end
    end
  end
end
