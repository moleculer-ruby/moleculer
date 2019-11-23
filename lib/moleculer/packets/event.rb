# frozen_string_literal: true

require_relative "base"

module Moleculer
  module Packets
    ##
    # Represents a EVENT packet
    class Event < Base
      packet_attr :event
      packet_attr :data
      packet_attr :broadcast
      packet_attr :groups
      packet_attr :broadcast
      packet_attr :groups, []
      packet_attr :node, nil

      def to_h
        super.merge(
          event:     event,
          data:      data,
          broadcast: broadcast,
          groups:    groups,
        )
      end

      def topic
        "#{super}.#{node.id}"
      end
    end
  end
end
