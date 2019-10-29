# frozen_string_literal: true

module Moleculer
  module Serializers
    ##
    # The base serializer that all other serializers inherit from
    class Base
      def initialize(config)
        @config = config
        @logger = config.logger.get_child("[SERIALIZER.#{@config.node_id}]")
      end

      private

      def deserialize_custom_fields(hash)
        new_hash = Support::HashUtil::HashWithIndifferentAccess.from_hash(hash)
        new_hash.merge!(deserialize_custom_field(:data, new_hash))
        new_hash.merge!(deserialize_custom_field(:services, new_hash))
        new_hash.merge!(deserialize_custom_field(:config, new_hash))
        new_hash.merge!(deserialize_custom_field(:params, new_hash))
        new_hash.merge(ip_list: new_hash) if new_hash[:ipList]
        new_hash
      end

      def serialize_custom_fields(hash)
        new_hash = Support::HashUtil::HashWithIndifferentAccess.from_hash(hash)
        new_hash.merge!(serialize_custom_field(:data, new_hash))
        new_hash.merge!(serialize_custom_field(:services, new_hash))
        new_hash.merge!(serialize_custom_field(:config, new_hash))
        new_hash.merge!(serialize_custom_field(:params, new_hash))
        new_hash.merge!(serialize_custom_field(:meta, new_hash))
        new_hash.merge(ipList: new_hash) if new_hash[:ip_list]
        new_hash
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
