# frozen_string_literal: true

require "msgpack"
require_relative "base"

module Moleculer
  module Serializers
    ##
    # Serializes data packets to and from MsgPack
    class MsgPack < Base
      ##
      # Serializes the provided packet to MsgPack
      #
      # @param packet [Moleculer::Packets::Base] the packet to serialize
      def serialize(packet)
        hash = packet.to_h
        hash = serialize_custom_fields(hash)
        MessagePack.pack(hash)
      end

      ##
      # Deserializes the provide message
      #
      # @param type [Moleculer::Packets::Base] the type of message
      # @param message [String] the message to deserialize
      def deserialize(type, message)
        hash = MessagePack.unpack(message)
        hash = deserialize_custom_fields(hash)
        Packets.for(type).new(@config, hash)
      end
    end
  end
end
