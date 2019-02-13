# frozen_string_literal: true

require_relative "./base"

module Moleculer
  module Packets
    class Ping < Base
      field :ver
      field :sender
      field :time
    end
  end
end
