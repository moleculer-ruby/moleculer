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
          class_eval <<-ATTR, __FILE__, __LINE__ + 1
            def #{name}
              default = self.class.packet_accessors[:#{name}]
              if default != :__not_defined__
                 return HashUtil.fetch(@data, :#{name}, default) unless default.is_a? Proc
                 return HashUtil.fetch(@data, :#{name}, default.call(self))
              end
              return HashUtil.fetch(@data, :#{name})
            end
          ATTR
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

      def as_json
        {
          ver:    ver,
          sender: sender,
        }
      end
    end
  end
end
