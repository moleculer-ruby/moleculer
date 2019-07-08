require_relative "base"

module Moleculer
  module Packets
    ##
    # Represents a REQ packet
    class Req < Base
      packet_attr :action
      packet_attr :params
      packet_attr :meta
      packet_attr :timeout, nil
      packet_attr :level, 1
      packet_attr :parent_id, nil
      packet_attr :request_id, nil
      packet_attr :stream, false
      packet_attr :metrics, false
      packet_attr :id
      packet_attr :node, nil

      def as_json # rubocop:disable Metrics/MethodLength
        super.merge(
          id:         id,
          action:     action,
          params:     params,
          meta:       meta,
          timeout:    timeout,
          level:      level,
          metrics:    metrics,
          parent_id:  parent_id,
          request_id: request_id,
          stream:     stream,
        )
      end

      def topic
        "#{super}.#{node.id}"
      end
    end
  end
end
