# frozen_string_literal: true

module Moleculer
  class Context
    attr_reader :broker, :params, :request_id, :parent_id, :options, :level, :metrics, :meta

    def initialize(params: {}, broker:, endpoint:, options:)
      @broker     = broker
      @params     = params
      @endpoint   = endpoint
      @options    = options
      @request_id = options[:request_id] || SecureRandom.hex(24)
      @node_id    = endpoint.node_id
    end
  end
end
