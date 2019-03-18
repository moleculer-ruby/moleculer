require_relative "../support/hash"

module Moleculer
  module Packets
    ##
    # @abstract Subclass for packet types.
    class Base
      ##
      # The protocol version
      attr_reader :ver

      ##
      # The sender of the packet
      attr_reader :sender

      ##
      # @param data [Hash] the raw packet data
      # @options data [String] :ver the protocol version, defaults to `'3'`
      # @options  data [String] :sender the packet sender, defaults to `Moleculer#node_id`
      def initialize(data = {})
        @ver    = data.fetch(:ver, "3")
        @sender = data.fetch(:sender, Moleculer.node_id)
      end

      ##
      # The publishing topic for the packet. This is used to publish packets to the moleculer network. Override as
      # needed.
      #
      # @return [String] the pub/sub topic to publish to
      def topic
        "MOL.#{self.class.name.split('::').last.upcase}"
      end
    end
  end
end
