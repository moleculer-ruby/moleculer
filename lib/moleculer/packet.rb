require_relative "./support/hash"

module Moleculer
  ##
  # Represents a Moleculer data packet
  class Packet < Moleculer::Support::Hash
    module Types
      DISCONNECT = "DISCONNECT".freeze
      DISCOVER   = "DISCOVER".freeze
      HEARTBEAT  = "HEARTBEAT".freeze
      INFO       = "INFO".freeze
      PING       = "PING".freeze
      PONG       = "PONG".freeze
      RESPONSE   = "RESPONSE".freeze
      REQUEST    = "REQ".freeze
      EVENT      = "EVENT".freeze
    end

    def initialize(packet, type)
      super nil
      merge!(self.class.from_hash(packet))
      merge!(ver: Moleculer::PROTOCOL_VERSION, sender: Moleculer.node_id, type: type)
    end
  end
end
