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

      def initialize(config, data)
        super(config, data)

        @id      = Support::Hash.fetch(data, :id)
        @success = Support::Hash.fetch(data, :success)
        @data    = Support::Hash.fetch(data, :data)
        @error   = Support::Hash.fetch(data, :error, nil)
        @meta    = Support::Hash.fetch(data, :meta)
        @stream  = Support::Hash.fetch(data, :stream, false)
        @node    = Support::Hash.fetch(data, :node, nil)
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
