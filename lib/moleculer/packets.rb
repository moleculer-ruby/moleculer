# frozen_string_literal: true

require_relative "packets/info"

module Moleculer
  module Packets
    TYPES = {
      Info::TOPIC => Info,
    }.freeze

    ##
    # Instantiates a packet from the command and deserialized payload.
    #
    # @param cmd [String] The command of the packet.
    # @param data [Hash] The deserialized payload of the packet.
    #
    # @return [Moleculer::Packet] The packet.
    def self.from(cmd, data)
      TYPES[cmd].new(data)
    end
  end
end
