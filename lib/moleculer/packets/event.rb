# frozen_string_literal: true

require_relative "./base"

module Moleculer
  module Packets
    class Event < Base
      attr_writer :target_node

      NAME = "EVENT"

      field :ver
      field :sender
      field :event
      field :data
      field :groups
      field :broadcast

      def topic
        "MOL.EVENT.#{@target_node}"
      end

      def sender
        Moleculer.node_id
      end
    end
  end
end
