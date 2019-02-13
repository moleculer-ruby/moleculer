# frozen_string_literal: true

require_relative "./base"

module Moleculer
  module Packets
    class Request < Base
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
    end
  end
end
