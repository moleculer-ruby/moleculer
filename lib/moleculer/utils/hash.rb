# frozen_string_literal: true

require "json"

require_relative "string"

module Moleculer
  module Utils
    ##
    # Utility methods for working with hashes
    module Hash
      extend self

      ##
      # Converts the provided hash to JSON excluding keys that cannot be converted
      #
      # @param hash [::Hash] the hash to convert to json
      #
      # @return [::String] json string representing the hash
      def to_json(hash)
        JSON.dump(::Hash[hash.map { |k, v| [camelize_key(json_convert(k)), json_convert(v)] }])
      end

      ##
      # Converts a json string to a normalized hash
      #
      # @param string [::String] a json encoded string
      #
      # @return [::Hash] a normalized hash
      def from_json(string)
        symbolize(JSON.parse(string))
      end

      ##
      # Returns a new hash with the keys converted to snake cased strings
      #
      # @param hash [::Hash] the hash to camelize
      #
      # @return [::Hash] copy of the hash with the keys camelized
      def camelize_hash(hash)
        ::Hash[hash.map { |k, v| [camelize_key(k), v.is_a?(::Hash) ? camelize_hash(v) : v] }]
      end

      ##
      # Returns a new hash with the keys symbolized, symbolizes keys of child hashes
      #
      # @param hash [::Hash] the hash to symbolize
      #
      # @return [::Hash] copy of the hash with the keys symbolized
      def symbolize(hash)
        ::Hash[hash.map do |k, v|
          new_child = v.is_a?(::Hash) ? symbolize(v) : v
          [symbolized_key(k), new_child]
        end]
      end

      private

      def json_convert(value, skip_camelization = false)
        case value
        when Array
          value.map { |v| json_convert(v) }
        when ::Hash
          ::Hash[value.map do |k, v|
            key   = k
            key   = camelize_key(k) unless skip_camelization
            value = if %w[actions events].include?(k.to_s)
                      json_convert(v, true)
                    else
                      json_convert(v)
                    end
            [key, value]
          end]
        when Integer
          value
        else
          value.to_s
        end
      end

      def camelize_key(key)
        can_symbolize?(key) ? String.camelize(key.to_s) : key
      end

      def symbolized_key(key)
        can_symbolize?(key) ? String.underscore(key.to_s).to_sym : key
      end

      def can_symbolize?(key)
        key.is_a?(::String) || key.is_a?(Symbol)
      end
    end
  end
end
