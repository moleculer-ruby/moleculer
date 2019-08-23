# frozen_string_literal: true

require_relative "protobuf/packets/packets.pb"

module Moleculer
  module Serializers
    module Protobuf
      ##
      # Protobuf serializer
      class Serializer
        PACKET_MAP = {
          Moleculer::Packets::Disconnect => Packets::PacketDisconnect,
          Moleculer::Packets::Discover   => Packets::PacketDiscover,
          Moleculer::Packets::Event      => Packets::PacketEvent,
          Moleculer::Packets::Heartbeat  => Packets::PacketHeartbeat,
          Moleculer::Packets::Info       => Packets::PacketInfo,
          Moleculer::Packets::Req        => Packets::PacketGossipRequest,
          Moleculer::Packets::Res        => Packets::PacketGossipResponse,
        }.freeze

        def initialize(config)
          @logger = config.logger.get_child("[SERIALIZER]")
          @config = config
        end

        ##
        # Serializes the packet using protobuf
        # @param packet [Moleculer::Packets::Base]
        def serialize(packet)
          hash  = packet.to_h
          hash  = serialize_special(:data, hash)
          hash  = serialize_special(:services, hash)
          hash  = serialize_special(:config, hash)
          hash  = serialize_special(:params, hash)
          hash  = serialize_special(:meta, hash)
          proto = PACKET_MAP[packet.class].new(hash)
          proto.encode
        end

        ##
        # Deserializes the provided message using protobuf
        # @param message [String] encoded protobuf message
        def deserialize_discover(message)
          Packets::PacketDiscover.decode(message)
        end

        private

        def serialize_special(key, hash)
          return hash.merge("#{key}": hash[key].to_json) if hash[key]

          hash
        end
      end
    end
  end
end
