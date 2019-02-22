# frozen_string_literal: true

require_relative "./base"

module Moleculer
  module Packets
    class Heartbeat < Base
      NAME = "HEARTBEAT"

      field :ver
      field :sender
      field :cpu
    end
  end
end
