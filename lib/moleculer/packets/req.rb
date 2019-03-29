require_relative "base"

module Moleculer
  module Packets
    ##
    # Represents a REQ packet
    class Req < Base
      attr_reader :action,
                  :params,
                  :meta,
                  :timeout,
                  :level,
                  :parent_id,
                  :request_id,
                  :stream,
                  :metrics,
                  :stream,
                  :id,
                  :node

      def initialize(data)
        super(data)

        @id         = HashUtil.fetch(data, :id)
        @action     = HashUtil.fetch(data, :action)
        @params     = HashUtil.fetch(data, :params)
        @meta       = HashUtil.fetch(data, :meta)
        @timeout    = HashUtil.fetch(data, :timeout, nil)
        @level      = HashUtil.fetch(data, :level, 1)
        @metrics    = HashUtil.fetch(data, :metrics, false)
        @parent_id  = HashUtil.fetch(data, :parent_id, nil)
        @request_id = HashUtil.fetch(data, :request_id, nil)
        @stream     = false
        @node       = HashUtil.fetch(data, :node, nil)
      end

      def as_json # rubocop:disable Metrics/MethodLength
        super.merge(
          id:         @id,
          action:     @action,
          params:     @params,
          meta:       @meta,
          timeout:    @timeout,
          level:      @level,
          metrics:    @metrics,
          parent_id:  @parent_id,
          request_id: @request_id,
          stream:     @stream,
        )
      end

      def topic
        "#{super}.#{@node.id}"
      end
    end
  end
end
