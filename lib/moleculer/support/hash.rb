# frozen_string_literal: true

require_relative "string_util"

module Moleculer
  module Support
    ##
    # A module of functional methods for working with hashes
    module Hash
      extend self

      ##
      # Returns a new hash with the keys symbolized
      #
      # @param hash [::Hash] the hash to symbolize
      #
      # @return [::Hash] copy of the hash with the keys symbolized
      def symbolize(hash)
        ::Hash[hash.collect do |k, v|
          [symbolized_key(k), v]
        end]
      end

      ##
      # Returns a new hash with the keys symbolized, symbolizes keys of child hashes
      #
      # @param hash [::Hash] the hash to symbolize
      #
      # @return [::Hash] copy of the hash with the keys symbolized
      def deep_symbolize(hash)
        ::Hash[hash.collect do |k, v|
          new_child = v.is_a?(::Hash) ? deep_symbolize(v) : nil
          [symbolized_key(k), new_child || v]
        end]
      end

      ##
      # Works like fetch, but instead indifferently uses strings and symbols. It will try both snake case and camel
      # case versions of the key.
      #
      # @param hash [Hash] the hash to fetch from
      # @param key [Object] the key to fetch from the hash. This uses Hash#fetch internally, and if a string or synbol
      # is passed the hash will use an indifferent fetch
      # @param default [Object] the a fallback default if fetch fails. If not provided an exception will be raised if
      #        key cannot be found
      #
      # @return [Object] the value at the given key
      def fetch(hash, key, default = :__no_default__)
        return fetch_with_string(hash, key, default) if key.is_a?(String) || key.is_a?(Symbol)
        return Support::Hash.fetch(key, default)     if default != :__no_default__

        Support::Hash.fetch(key)
      end

      private

      def symbolized_key(key)
        key.is_a?(String) ? key.to_sym : key
      end

      def fetch_with_string(hash, key, default)
        ret = get_camel(hash, key).nil? ? get_underscore(hash, key) : get_camel(hash, key)
        return default if default != :__no_default__ && ret.nil?
        raise KeyError, %(key not found: "#{key}") if ret.nil?

        ret
      end

      def get_camel(hash, key)
        camelized = StringUtil.camelize(key.to_s)
        hash[camelized].nil? ? hash[camelized.to_sym] : hash[camelized]
      end

      def get_underscore(hash, key)
        underscored = StringUtil.underscore(key.to_s)
        hash[underscored].nil? ? hash[underscored.to_sym] : hash[underscored]
      end
    end
  end
end
