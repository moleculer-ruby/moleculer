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

      def initialize(config, data={})
        super(config, data)

        @event     = HashUtil.fetch(data, :event)
        @data      = HashUtil.fetch(data, :data)
        @broadcast = HashUtil.fetch(data, :broadcast)
        @groups    = HashUtil.fetch(data, :groups, [])
        @node      = HashUtil.fetch(data, :node, nil)
      end

      def as_json
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
