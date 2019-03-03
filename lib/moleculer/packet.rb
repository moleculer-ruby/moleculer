require_relative "./support/hash"

module Moleculer
  ##
  # Represents a Moleculer data packet
  class Packet < Moleculer::Support::Hash
    def initialize(packet)
      super nil
      merge!(self.class.from_hash(packet))
      merge!(ver: Moleculer::PROTOCOL_VERSION, sender: Moleculer.node_id)
    end
  end
end
