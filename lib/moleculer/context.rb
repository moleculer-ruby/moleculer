module Moleculer
  class Context

    def initialize(broker, action, request_id, params, meta, parent_id = nil, level = 1)
      @id         = SecureRandom.uuid
      @broker     = broker
      @action     = action
      @request_id = request_id
      @parent_id  = parent_id
      @params     = params
      @meta       = meta
      @level      = level
    end

  end
end
