# frozen_string_literal: true

require_relative "base"

module Moleculer
  module Packets
    ##
    # Represents a EVENT packet
    class Event < Base
      attr_reader :event,
                  :data,
                  :broadcast,
                  :groups

      def initialize(config, data = {})
        super(config, data)

        @event     = Support::Hash.fetch(data, :event)
        @data      = Support::Hash.fetch(data, :data)
        @broadcast = Support::Hash.fetch(data, :broadcast)
        @groups    = Support::Hash.fetch(data, :groups, [])
        @node      = Support::Hash.fetch(data, :node, nil)
      end

      def to_h
        super.merge(
          event:     @event,
          data:      @data,
          broadcast: @broadcast,
          groups:    @groups,
        )
      end

      def topic
        "#{super}.#{@node.id}"
      end
    end
  end
end
