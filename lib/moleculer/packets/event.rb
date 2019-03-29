require_relative "base"

module Moleculer
  module Packets
    ##
    # Represents a EVENT packet
    class Event < Base
      attr_reader :id,
                  :event,
                  :data,
                  :broadcast

      def initialize(data)
        super(data)

        @id        = HashUtil.fetch(data, :id)
        @event     = HashUtil.fetch(data, :event)
        @data      = HashUtil.fetch(data, :data)
        @broadcast = HashUtil.fetch(data, :broadcast)
        @node      = HashUtil.fetch(data, :node, nil)
      end

      def as_json
        super.merge(
          id:        @id,
          event:     @event,
          data:      @data,
          broadcast: @broadcast,
        )
      end

      def topic
        "#{super}.#{@node.id}"
      end
    end
  end
end
