# frozen_string_literal: true

require_relative "targeted_base"

module Moleculer
  module Packets
    ##
    # Represents a RES packet
    class Res < TargetedBase
      packet_attr :id
      packet_attr :success
      packet_attr :data
      packet_attr :error, nil
      packet_attr :meta, {}
      packet_attr :stream, false

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
