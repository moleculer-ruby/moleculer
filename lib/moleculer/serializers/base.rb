# frozen_string_literal: true

module Moleculer
  module Serializers
    ##
    # The base serializer that all other serializers inherit from
    class Base
      PACKET_TYPE_MAP = {
        disconnect: Moleculer::Packets::Disconnect,
        discover:   Moleculer::Packets::Discover,
        event:      Moleculer::Packets::Event,
        heartbeat:  Moleculer::Packets::Heartbeat,
        info:       Moleculer::Packets::Info,
        req:        Moleculer::Packets::Req,
        res:        Moleculer::Packets::Res,
      }.freeze

      def initialize(config)
        @config = config
        @logger = config.logger.get_child("[SERIALIZER]")
      end

      private

      def deserialize_custom_fields(hash)
        hash  = deserialize_custom_field(:data, hash)
        hash  = deserialize_custom_field(:services, hash)
        hash  = deserialize_custom_field(:config, hash)
        hash  = deserialize_custom_field(:params, hash)
        hash.merge(ip_list: hash.delete(:ipList)) if hash[:ipList]
        hash
      end

      def serialize_custom_fields(hash)
        hash  = serialize_custom_field(:data, hash)
        hash  = serialize_custom_field(:services, hash)
        hash  = serialize_custom_field(:config, hash)
        hash  = serialize_custom_field(:params, hash)
        hash  = serialize_custom_field(:meta, hash)
        hash.merge(ipList: hash.delete(:ip_list)) if hash[:ip_list]
        hash
      end

      def serialize_custom_field(key, hash)
        return hash.merge("#{key}": hash[key].to_json) if hash[key]

        hash
      end

      def deserialize_custom_field(key, hash)
        return hash.merge("#{key}": JSON.parse(hash[key])) if hash[key] && !hash[key].is_a?(Hash)

        hash
      end
    end
  end
end
