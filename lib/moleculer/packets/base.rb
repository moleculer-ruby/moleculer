require_relative "../support"

module Moleculer
  module Packets
    ##
    # @abstract Subclass for packet types.
    class Base
      include Support
      ##
      # The protocol version
      attr_reader :ver

      ##
      # The sender of the packet
      attr_reader :sender

      def self.packet_name
        name.split("::").last.upcase
      end

      ##
      # @param data [Hash] the raw packet data
      # @options data [String] :ver the protocol version, defaults to `'3'`
      # @options  data [String] :sender the packet sender, defaults to `Moleculer#node_id`
      def initialize(broker, data = {})
        @ver    = HashUtil.fetch(data, :ver, "3")
        @sender = HashUtil.fetch(data, :sender, broker.config.node_id)
      end

      ##
      # The publishing topic for the packet. This is used to publish packets to the moleculer network. Override as
      # needed.
      #
      # @return [String] the pub/sub topic to publish to
      def topic
        "MOL.#{self.class.packet_name}"
      end

      def as_json
        {
          ver:    ver,
          sender: sender,
        }
      end
    end
  end
end
