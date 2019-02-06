# frozen_string_literal: true

require_relative "./base"

module Moleculer
  module Packets
    # @private
    class Request < Base
      field :ver
      field :sender
      field :id
      field :success
      field :data
      field :error
      field :meta
      field :stream
    end
  end
end
