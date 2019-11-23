# frozen_string_literal: true

require_relative "../support"

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
          define_method name do
            return Support::Hash.fetch(@data, name) if default == :__not_defined__

            fetch_with_default(@data, name, default)
          end
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
        @data   = data
        @config = config
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

      def fetch_with_default(hash, key, default)
        return Support::Hash.fetch(hash, key, default) unless default.is_a? Proc

        begin
          return Support::Hash.fetch(hash, key)
        rescue KeyError
          return default.call(self)
        end
      end
    end
  end
end
