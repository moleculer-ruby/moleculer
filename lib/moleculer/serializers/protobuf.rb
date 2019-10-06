# frozen_string_literal: true

require_relative "protobuf/packets/packets.pb"
require_relative "base"

module Moleculer
  module Serializers
    ##
    # Protobuf serializer
    module Protobuf
      ##
      # because of the way the Protobuf compiler works, we need to fudge this to comply with how Moleculer expects
      # the serializer class standard
      def self.new(*args)
        Serializer.new(*args)
      end

      ##
      # @private
      class Serializer < Serializers::Base
        PROTOBUF_PACKET_MAP = {
          Moleculer::Packets::Disconnect => Packets::PacketDisconnect,
          Moleculer::Packets::Discover   => Packets::PacketDiscover,
          Moleculer::Packets::Event      => Packets::PacketEvent,
          Moleculer::Packets::Heartbeat  => Packets::PacketHeartbeat,
          Moleculer::Packets::Info       => Packets::PacketInfo,
          Moleculer::Packets::Req        => Packets::PacketRequest,
          Moleculer::Packets::Res        => Packets::PacketResponse,
        }.freeze

        ##
        # Serializes the packet using protobuf
        # @param packet [Moleculer::Packets::Base]
        def serialize(packet)
          hash  = serialize_custom_fields(packet.to_h)
          proto = PROTOBUF_PACKET_MAP[packet.class].new(hash)
          proto.encode
        end

        ##
        # Deserializes the provided message using protobuf
        # @param message [String] encoded protobuf message
        def deserialize(type, message)
          proto = protobuf_packet_for(type).decode(message)
          hash  = deserialize_custom_fields(proto.to_hash)
          Moleculer::Packets.for(type).new(@config, hash)
        end

        private

        def protobuf_packet_for(type)
          PROTOBUF_PACKET_MAP[Moleculer::Packets.for(type)]
        end
      end
    end
  end
end
