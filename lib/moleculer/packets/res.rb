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

        @id      = Hash.fetch(data, :id)
        @success = Hash.fetch(data, :success)
        @data    = Hash.fetch(data, :data)
        @error   = Hash.fetch(data, :error, nil)
        @meta    = Hash.fetch(data, :meta)
        @stream  = Hash.fetch(data, :stream, false)
        @node    = Hash.fetch(data, :node, nil)
      end

      def topic
        "#{super}.#{@node.id}"
      end

      def to_h
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
