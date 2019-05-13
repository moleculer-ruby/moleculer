module Moleculer
  ##
  # A transporter is the method by which moleculer transports information from one service to the next. Transporters can
  # be created using any over-the-wire bus that can be made to support some level of queueing (i.e. Redis, NATS, Kafka)
  module Transporters
    ##
    # All transporters inherit from this class. The Base class simply defines an interface that transporters should
    # adhere to.
    class Base
      ##
      # @param config [Moleculer::Configuration] the transporter configuration.
      def initialize(config)
        @config = config
      end

      ##
      # Subscribes to the given channel on the transporter's message bus
      # @param channel [String] the channel to which to subscribe
      def subscribe(_channel, &_block)
        raise NotImplementedError
      end

      ##
      # Publishes the provided packet to the transporter's message bus. The publish method is expected to implement the
      # method of translating the packet data into the channel information on which to publish.
      # @param packet [Moleculer::Packet::Base] the packet to publish to the network.
      def publish(_packet)
        raise NotImplementedError
      end

      ##
      # Starts the transporter, and activates all of the subscriptions. The subscriptions should not start consuming
      # until the start method has been called.
      def start
        raise NotImplementedError
      end

      ##
      # Stops the transporter, and stops all subscriptions from consuming
      def stop
        raise NotImplementedError
      end
    end
  end
end
