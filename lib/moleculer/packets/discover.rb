# frozen_string_literal: true

require_relative "base"

module Moleculer
  module Packets
    ##
    # Represents a DISCOVER packet
    class Discover < Base
      packet_attr :node_id, nil

      def topic
        return "#{super}.#{node_id}" if node_id

        super
      end
    end
  end
end
