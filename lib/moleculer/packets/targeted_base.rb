# frozen_string_literal: true

require_relative "base"

module Moleculer
  module Packets
    ##
    # @abstract Subclass targetted for packet types.
    class TargetedBase < Base
      packet_attr :target_node


      def topic
        "#{super}.#{target_node}"
      end
    end
  end
end
