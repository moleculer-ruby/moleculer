# frozen_string_literal: true

require "json"
require_relative "base"

module Moleculer
  module Serializers
    ##
    # Serializes data packets to and from JSON
    class Json < Base
      ##
      # Serializes the provided packet to json
      #
      # @param packet [Moleculer::Packets::Base] the packet to serialize
      def serialize(packet)
        hash = packet.to_h
        hash = serialize_custom_fields(hash)
        hash.to_json
      end

      ##
      # Deserializes the provided message
      #
      # @param type [Moleculer::Packets::Base] the type of message
      # @param message [String] the message to deserialize
      def deserialize(type, message)
        hash = JSON.parse(message)
        hash = deserialize_custom_fields(hash)
        PACKET_TYPE_MAP[type].new(@config, hash)
      end
    end
  end
end
