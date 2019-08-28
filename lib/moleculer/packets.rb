# frozen_string_literal: true

require_relative "packets/disconnect"
require_relative "packets/discover"
require_relative "packets/event"
require_relative "packets/heartbeat"
require_relative "packets/info"
require_relative "packets/req"
require_relative "packets/res"

module Moleculer
  ##
  # Encapsulates Moleculer packets
  module Packets
    def self.packet_type(klass)
      klass.packet_name.downcase.to_sym
    end

    private_class_method :packet_type

    TYPES = {
      "#{packet_type(Discover)}":   Discover,
      "#{packet_type(Info)}":       Info,
      "#{packet_type(Req)}":        Req,
      "#{packet_type(Res)}":        Res,
      "#{packet_type(Heartbeat)}":  Heartbeat,
      "#{packet_type(Event)}":      Event,
      "#{packet_type(Disconnect)}": Disconnect,
    }.freeze

    def self.for(type)
      TYPES[type.downcase.to_sym]
    end
  end
end
