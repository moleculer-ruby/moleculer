# frozen_string_literal: true

require_relative "string_util"

module Moleculer
  module Support
    ##
    # A module of functional methods for working with hashes
    module HashUtil
      extend self

      ##
      # This is a hacked together clone of ActiveSupports hash with indifferent access
      class HashWithIndifferentAccess < Concurrent::Hash
        ##
        # Create a HashWithIndifferentAccess from a normal hash
        #
        # @param obj [Hash] the Hash to convert into a HashWithIndifferentAccess
        def self.from_hash(obj)
          self[with_normalized_keys(obj)]
        end

        ##
        # @private
        def self.with_normalized_keys(hash)
          new_hash = hash.clone
          new_hash.each do |key, value|
            next unless key.is_a?(String) || key.is_a?(Symbol)

            symbolized_key = StringUtil.underscore(key.to_s).to_sym

            new_hash                 = wipe(new_hash, key)
            new_hash[symbolized_key] = value.is_a?(Hash) ? from_hash(value) : value
          end
          new_hash
        end

        ##
        # @private
        def self.wipe(hash, key)
          stringified = key.to_s
          camlelized  = StringUtil.camelize(stringified)
          underscored = StringUtil.underscore(stringified)
          new_hash    = hash.clone

          new_hash.delete(camlelized.to_sym)
          new_hash.delete(underscored.to_sym)
          new_hash.delete(camlelized)
          new_hash.delete(underscored)
          new_hash
        end

        ##
        # Returns a new HashWithIndifferentAccess with all keys stringified
        def stringify_keys
          new_hash = clone
          new_hash.keys.each do |key|
            next unless key.is_a? Symbol

            value              = new_hash.delete(key)
            value              = self.class.from_hash(value).stringify_keys if value.is_a? Hash
            new_hash[key.to_s] = value
          end
          new_hash
        end

        def merge(other)
          super(self.class.from_hash(other))
        end

        ##
        # Returns a hash where all keys are camelized
        def to_camelized_hash
          new_hash = {}
          each do |key, value|
            unless key.is_a? Symbol
            new_hash[key] = value
            next
            end

            value = self.class.from_hash(value).to_camelized_hash if value.is_a? Hash
            new_hash[StringUtil.camelize(key.to_s)] = value
          end
          new_hash
        end

        ##
        # Returns the camelized hash as JSON excluding values where the keys are objects
        def to_json(*args)
          to_camelized_hash.select { |k, _| k.is_a? String }.to_json(*args)
        end
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
        return hash.fetch(key, default) if default != :__no_default__

        hash.fetch(key)
      end

      ##
      # Returns a new hash with the keys stringified
      #
      # @param hash [Hash] the hash whose keys to stringify
      def stringify_keys(hash)
        new_hash = hash.clone
        new_hash.keys.each do |key|
          value              = new_hash.delete(key)
          value              = stringify_keys(value) if value.is_a? Hash
          new_hash[key.to_s] = value
        end
        hash
      end

      ##
      # Returns a new hash with the keys symbolized
      #
      # @param hash [Hash] the hash whose keys to symbolize
      def symbolize_keys(hash)
        new_hash = hash.clone
        new_hash.keys.each do |key|
          value                = new_hash.delete(key)
          value                = symbolize_keys(value) if value.is_a? Hash
          new_hash[key.to_sym] = value
        end
        new_hash
      end

      private

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
