module Moleculer
  module Support
    ##
    # An extension of Concurrent::Map that automatically symbolizes keys
    class Hash < Hash

      ##
      # Creates a new Moleculer::Support::Hash from the provided hash
      #
      # @param hash [Hash] the has to convert to a Moleculer::Support::Hash
      def self.from_hash(hash)
        self[hash.to_a]
      end

      def self.[](array)
        super array.collect { |a| [a[0].to_sym, a[1]] }
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
