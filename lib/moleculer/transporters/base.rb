module Moleculer
  module Transporters
    ##
    # @abstract
    # Defines the basic interface of a transporter. Transporters must define a NAME constant.
    class Base

      ##
      # @param [String] uri the transporter uri
      # @param [Moleculer::Broker] broker the broker instance
      def initialize(uri, broker)
        @broker = broker
        @uri = uri
        @logger = Moleculer.logger
        @started = Concurrent::AtomicBoolean.new
        @serializer = Serializers.for(Moleculer.serializer)
      end

      ##
      # @abstract Subclass and override {#publish} to implement the #publish method for a given
      # transporter
      def publish(packet)
        raise NotImplementedError
      end

      ##
      # @abstract Subclass and override {#connect} to implement the #connect method for a given
      # transporter
      def connect
        raise NotImplementedError
      end

      ##
      # @abstract Subclass and override {#subscribe} to implement the #subscribe method for a given
      # transporter
      def subscribe(topic, &block)
        raise NotImplementedError
      end
    end
  end
end
