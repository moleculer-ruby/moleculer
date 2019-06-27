require_relative "base"

module Moleculer
  module Packets
    ##
    # Represents a RES packet
    class Res < Base
      attr_reader :id,
                  :success,
                  :data,
                  :error,
                  :meta,
                  :stream

      def initialize(config, data)
        super(config, data)

        @id      = HashUtil.fetch(data, :id)
        @success = HashUtil.fetch(data, :success)
        @data    = HashUtil.fetch(data, :data)
        @error   = HashUtil.fetch(data, :error, nil)
        @meta    = HashUtil.fetch(data, :meta)
        @stream  = HashUtil.fetch(data, :stream, false)
        @node    = HashUtil.fetch(data, :node, nil)
      end

      def topic
        "#{super}.#{@node.id}"
      end

      def as_json
        super.merge(
          id:      @id,
          success: @success,
          data:    @data,
          error:   @error,
          meta:    @meta,
          stream:  @stream,
        )
      end
    end
  end
end
