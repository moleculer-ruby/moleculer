# frozen_string_literal: true

module Moleculer
  ##
  # Packet for transporters
  class Packet
    TYPES = [
      UNKNOWN = "????",
      EVENT = "EVENT",
      REQUEST = "REQ",
      RESPONSE = "RES",
      DISCOVER = "DISCOVER",
      INFO = "INFO",
      DISCONNECT = "DISCONNECT",
      HEARTBEAT = "HEARTBEAT",
      PING = "PING",
      PONG = "PONG",

      GOSSIP_REQ = "GOSSIP_REQ",
      GOSSIP_RES = "GOSSIP_RES",
      GOSSIP_HELLO = "GOSSIP_HELLO"
    ].freeze

    DATATYPES = [
      UNDEFINED = 0,
      NULL = 1,
      JSON = 2,
      BUFFER = 3
    ].freeze

    extend Dry::Initializer

    option :type, optional: true, type: Types::String.enum(*TYPES), default: -> { UNKNOWN }
    option :target, type: Types::String
    option :payload, optional: true, type: Types::Any, default: -> { {} }
  end
end
