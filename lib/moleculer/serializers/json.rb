require "json"

module Moleculer
  module Serializers
    ##
    # Serializes data packets to and from JSON
    class Json
      def initialize(config)
        @logger = config.logger.get_child("[SERIALIZER]")
        @config = config
      end

      def serialize(message)
        message.to_h.to_json
      end

      def deserialize(message)
        JSON.parse(message)
      rescue StandardError => e
        @config.handle_error(e)
      end
    end
  end
end
