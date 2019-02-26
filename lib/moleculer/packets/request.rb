# frozen_string_literal: true
require "securerandom"

require_relative "./base"

module Moleculer
  module Packets
    class Request < Base
      attr_writer :target_node

      NAME = "REQ"

      field :ver
      field :sender
      field :id
      field :action
      field :params
      field :meta
      field :timeout
      field :level
      field :metrics
      field :parentID
      field :requestID
      field :stream

      def initialize(options)
        super(options)
        @data[:id] = SecureRandom.uuid
        @data[:sender] = Moleculer.node_id
      end

      def topic
        "MOL.REQ.#{@target_node.name}"
      end

    end
  end
end
