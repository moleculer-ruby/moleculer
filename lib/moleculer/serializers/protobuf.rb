# frozen_string_literal: true

require_relative "protobuf/packets/packets.pb"
require_relative "base"

module Moleculer
  module Serializers
    module Protobuf
      ##
      # Protobuf serializer
      class Serializer < Serializers::Base
        PACKET_MAP = {
          Moleculer::Packets::Disconnect => Packets::PacketDisconnect,
          Moleculer::Packets::Discover   => Packets::PacketDiscover,
          Moleculer::Packets::Event      => Packets::PacketEvent,
          Moleculer::Packets::Heartbeat  => Packets::PacketHeartbeat,
          Moleculer::Packets::Info       => Packets::PacketInfo,
          Moleculer::Packets::Req        => Packets::PacketRequest,
          Moleculer::Packets::Res        => Packets::PacketResponse,
        }.freeze

        PACKET_TYPE_MAP = {
          disconnect: Moleculer::Packets::Disconnect,
          discover:   Moleculer::Packets::Discover,
          event:      Moleculer::Packets::Event,
          heartbeat:  Moleculer::Packets::Heartbeat,
          info:       Moleculer::Packets::Info,
          req:        Moleculer::Packets::Req,
          res:        Moleculer::Packets::Res,
        }.freeze

        ##
        # Serializes the packet using protobuf
        # @param packet [Moleculer::Packets::Base]
        def serialize(packet)
          hash = serialize_custom_fields(packet.to_h)
          proto = PACKET_MAP[packet.class].new(hash)
          proto.encode
        end

        ##
        # Deserializes the provided message using protobuf
        # @param message [String] encoded protobuf message
        def deserialize(type, message)
          proto = protobuf_packet_for(type).decode(message)
          hash = deserialize_custom_fields(type, proto.to_hash)
          PACKET_TYPE_MAP[type].new(@config, hash)
        end

        private

        def protobuf_packet_for(type)
          PACKET_MAP[PACKET_TYPE_MAP[type]]
        end
      end
    end
  end
end
