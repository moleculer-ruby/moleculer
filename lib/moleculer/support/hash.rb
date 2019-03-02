module Moleculer
  module Support
    ##
    # An extension of Concurrent::Map that automatically symbolizes keys
    class Hash < Hash
      def [](key)
        super key.to_sym
      end

      def []=(key, value)
        super key.to_sym, value
      end
    end
  end
end
