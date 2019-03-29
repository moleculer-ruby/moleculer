require_relative "packets/disconnect"
require_relative "packets/discover"
require_relative "packets/event"
require_relative "packets/heartbeat"
require_relative "packets/info"
require_relative "packets/req"
require_relative "packets/res"

module Moleculer
  module Packets
    TYPES = {
      Discover.packet_name   => Discover,
      Info.packet_name       => Info,
      Req.packet_name        => Req,
      Res.packet_name        => Res,
      Heartbeat.packet_name  => Heartbeat,
      Event.packet_name      => Event,
      Disconnect.packet_name => Disconnect,
    }.freeze

    def self.for(type)
      TYPES[type.to_s.upcase]
    end
  end
end
