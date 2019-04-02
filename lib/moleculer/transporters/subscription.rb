module Moleculer
  module Transporters
    ##
    # Provides an interface for processing incoming data from transporters
    class Subscription

      ##
      # @param transporter [Moleculer::Transporter::Base] the transporter
      # @param channel [String] the channel to which to subscribe
      # @param block [Proc] the block to which to call when the subscription receives a message
      def initialize(transporter, channel, block)
        @transporter = transporter
        @channel     = channel
        @block       = block
      end

      def start
        @thread = @transporter.subscribe(@channel, &block)
      end

    end
  end
end