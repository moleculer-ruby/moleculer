require "uri"

require "moleculer/transporters/redis"

module Moleculer
  module Transporters
    SCHEMES = {
      redis: Redis
    }.freeze


    def self.for(uri)
      parsed = URI(uri)

      SCHEMES[parsed.scheme.to_sym]
    end
  end
end
