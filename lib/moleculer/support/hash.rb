module Moleculer
  module Support
    ##
    # An extension of Concurrent::Map that automatically symbolizes keys
    class Hash < ::Hash

      ##
      # Creates a new Moleculer::Support::Hash from the provided hash
      #
      # @param hash [Hash] the has to convert to a Moleculer::Support::Hash
      def self.from_hash(hash)
        hsh = self[]
        hash.each do |key, value|
          case value
          when ::Hash
            hsh[key] = from_hash(value)
          when ::Array
            hsh[key] =  _parse_array(value)
          else
            hsh[key] = value
          end
        end
        hsh
      end

      def self._parse_array(array)
        array.map do |value|
          case value
          when ::Hash
            from_hash(value)
          when ::Array
            _parse_array(value)
          else
            value
          end
        end
      end


      def merge(other_hash)
        super self.class.from_hash(other_hash)
      end

      def merge!(other_hash)
        super self.class.from_hash(other_hash)
      end

      def [](key)
        super key.to_sym
      end

      def []=(key, value)
        super key.to_sym, value
      end

      def fetch(key, default=nil, &block)
        super key.to_sym, default, &block
      end
    end
  end
end
