# frozen_string_literal: true

require_relative "service/base"

module Moleculer
  module Service
    def self.from_schema(schema)
      Class.new(Moleculer::Service::Base) do
        service_name(schema["name"])

        schema["actions"].each do |name, options|
          action(name.gsub(/^.+\./, ""), :__remote__, options)
        end

        schema["events"].each do |name, options|
          event(name.gsub(/^.+\./, ""), :__remote__, options)
        end
      end
    end
  end
end
