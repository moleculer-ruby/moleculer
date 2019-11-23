# frozen_string_literal: true

require_relative "base"

module Moleculer
  module Packets
    ##
    # Represents a RES packet
    class Res < Base
      packet_attr :id
      packet_attr :data
      packet_attr :success
      packet_attr :error, nil
      packet_attr :meta
      packet_attr :stream, false
      packet_attr :node, nil

      def topic
        "#{super}.#{node.id}"
      end

      def to_h
        super.merge(
          id:      id,
          success: success,
          data:    data,
          error:   error,
          meta:    meta,
          stream:  stream,
        )
      end
    end
  end
end
