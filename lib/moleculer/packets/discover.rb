require_relative "base"

module Moleculer
  module Packets
    ##
    # Represents a DISCOVER packet
    class Discover < Base
      def initialize(config, data)
        super(config, data)

        node = HashUtil.fetch(data, :node, nil)
        @node_id = HashUtil.fetch(data, :node_id, node)
      end

      def topic
        if @node_id
          return "#{super}.#{@node_id}"
        end
        super
      end
    end
  end
end
