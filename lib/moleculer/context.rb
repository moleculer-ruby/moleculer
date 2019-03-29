module Moleculer
  class Context
    attr_reader :request_id,
                :action,
                :params,
                :meta,
                :level,
                :timeout,
                :id

    def initialize(broker:, action:, params:, meta:, parent_id: nil, level: 1, timeout:, id: nil)
      @id         = id ? id : SecureRandom.uuid
      @broker     = broker
      @action     = action
      @request_id = SecureRandom.uuid
      @parent_id  = parent_id
      @params     = params
      @meta       = meta
      @level      = level
      @timeout    = timeout
    end

  end
end
