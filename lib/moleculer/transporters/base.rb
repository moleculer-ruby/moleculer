module Moleculer
  module Transporters
    class Base

      def initialize(broker, uri)
        @broker = broker
        @uri = uri
      end

      def join
        raise NotImplementedError
      end

      def publish(packet)
        raise NotImplementedError
      end

      def connect
        raise NotImplementedError
      end

      def name
        self.class::NAME
      end

      def subscribe(topic, &block)
        raise NotImplementedError
      end
    end
  end
end
