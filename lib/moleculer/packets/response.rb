# frozen_string_literal: true

require_relative "./base"

module Moleculer
  module Packets
    class Response < Base
      NAME = "RES".freeze

      field :ver
      field :sender
      field :id
      field :success
      field :data
      field :error
      field :meta
      field :stream

      def initialize(options, request=nil)
        super(options)
        @request = request
      end

      def topic
        "MOL.#{name}.#{@request.sender}"
      end

    end
  end
end
