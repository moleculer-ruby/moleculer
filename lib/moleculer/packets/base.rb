# frozen_string_literal: true

require_relative "../support"
require_relative "../errors/missing_value"

module Moleculer
  module Packets
    ##
    # @abstract Subclass for packet types.
    class Base
      include Support

      class << self
        # this ensures that the packets get the accessors from the parent
        def inherited(other)
          other.instance_variable_set(:@packet_accessors, other.packet_accessors.merge(packet_accessors))
        end

        def packet_accessors
          @packet_accessors ||= {}
        end

        ##
        # Sets an accessor that fetches @data attributes
        def packet_attr(name, default = :__not_defined__)
          packet_accessors[name] = default
        end

        def packet_name
          name.split("::").last.upcase
        end
      end

      ##
      # The protocol version
      packet_attr :ver, "3"

      ##
      # The sender of the packet
      packet_attr :sender, ->(packet) { packet.config.node_id }

      attr_reader :config

      ##
      # @param data [Hash] the raw packet data
      # @options data [String] :ver the protocol version, defaults to `'3'`
      # @options  data [String] :sender the packet sender, defaults to `Moleculer#node_id`
      def initialize(config, data = {})
        @data   = HashUtil::HashWithIndifferentAccess.from_hash(data)
        @config = config
      end

      ##
      # Compares one packet to another. Packets are equal if the internal data is equal
      # @param other [Base] the object to compare against
      def ==(other)
        return false unless other.is_a?(Base)
        return false unless other.class == self.class

        self.class.packet_accessors.select do |k, _|
          send(k) == other.send(k)
        end
      end

      ##
      # The publishing topic for the packet. This is used to publish packets to the moleculer network. Override as
      # needed.
      #
      # @return [String] the pub/sub topic to publish to
      def topic
        "MOL.#{self.class.packet_name}"
      end

      def to_h
        {
          ver:    ver,
          sender: sender,
        }
      end

      private

      def method_missing(meth, *args, &block)
        accessor = self.class.packet_accessors[meth]
        if self.class.packet_accessors.key?(meth)
          return @data[meth] unless @data[meth].nil?
          return accessor.call(self) if accessor.is_a? Proc
          return accessor unless accessor == :__not_defined__

          raise Errors::MissingValue, meth
        end

        super
      end

      def respond_to_missing?(meth, include_private = false)
        self.class.packet_accessors[meth] || super
      end
    end
  end
end
