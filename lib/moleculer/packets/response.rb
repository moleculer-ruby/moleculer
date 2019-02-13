# frozen_string_literal: true

require_relative "./base"

module Moleculer
  module Packets
    class Response < Base
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
