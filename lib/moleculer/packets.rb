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
    TYPES = {
      Discover.packet_name.downcase.to_sym   => Discover,
      Info.packet_name.downcase.to_sym       => Info,
      Req.packet_name.downcase.to_sym        => Req,
      Res.packet_name.downcase.to_sym        => Res,
      Heartbeat.packet_name.downcase.to_sym  => Heartbeat,
      Event.packet_name.downcase.to_sym      => Event,
      Disconnect.packet_name.downcase.to_sym => Disconnect,
    }.freeze

    def self.for(type)
      TYPES[type.downcase.to_sym]
    end
  end
end
