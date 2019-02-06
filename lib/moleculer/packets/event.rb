require_relative "./base"

module Moleculer
  module Packets
    class  Event < Base
      field :ver
      field :sender
      field :event
      field :data
      field :groups
      field :broadcast
    end
  end
end
