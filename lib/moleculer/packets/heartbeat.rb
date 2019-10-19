# frozen_string_literal: true

require_relative "base"

module Moleculer
  module Packets
    ##
    # Represents a DISCOVER packet
    class Heartbeat < Base
      packet_attr :cpu, 0
    end
  end
end
