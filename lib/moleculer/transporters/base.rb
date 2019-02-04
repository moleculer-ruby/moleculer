module Moleculer
  module Transporters
    class Base

      def initialize(broker:, uri:)
        @broker = broker
        @uri = uri
      end

      def connect
        raise NotImplementedError
      end

      def name
        self.class::NAME
      end

    end
  end
end
