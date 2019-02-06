# frozen_string_literal: true

require_relative "./base"

module Moleculer
  module Packets
    # @private
    class Event < Base
      field :ver
      field :sender
      field :event
      field :data
      field :groups
      field :broadcast
    end
  end
end
