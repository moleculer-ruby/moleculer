require_relative "../support/hash"

module Moleculer
  module Packets
    ##
    # @abstract
    # Represents a Moleculer data packet
    class Base < Moleculer::Support::Hash
      def initialize(data = {})
        super(nil)
        merge!(ver: Moleculer::PROTOCOL_VERSION, sender: Moleculer.node_id)
        merge!(data)
      end

      def topic
        "MOL.#{self.class::NAME}"
      end
    end
  end
end
