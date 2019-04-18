module Moleculer
  module Serializers

    def self.for(serializer)
      require_relative("serializers/#{serializer}")
      Serializers.const_get(serializer.to_s.split("_").map(&:capitalize).join)
    end

  end
end