require_relative "packets/discover"
require_relative "packets/info"

module Moleculer
  module Packets
    TYPES = {
      Discover.packet_name=> Discover,
      Info.packet_name => Info,
    }.freeze

    def self.for(type)
      TYPES[type.to_s.upcase]
    end
  end
end
