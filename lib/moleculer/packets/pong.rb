# frozen_string_literal: true

require_relative "./base"

module Moleculer
  module Packets
    class Pong < Base
      field :ver
      field :sender
      field :time
      field :arrived
    end
  end
end
