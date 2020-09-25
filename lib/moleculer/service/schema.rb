# frozen_string_literal: true

module Moleculer
  module Service
    module Schema
      module ClassMethods
        def from_schema(schema)
          Class.new(self) do
            # Parse actions into remote actions
            schema[:actions].each do |name, _options|
              action name do |service, params = {}, **opts|
                service.broker.call(
                  name.to_s,
                  params,
                  **opts.merge(remote: true),
                )
              end
            end

            # parse events into remote events
            schema[:events].each do |name, _options|
              event name do |service, payload = {}, **opts|
                service.broker.emit(
                  name,
                  payload,
                  **opts.merge(remote: true),
                )
              end
            end
          end
        end
      end

      def self.included(mod)
        mod.extend ClassMethods
      end

      # @return [Hash] the service schema
      def schema
        {
          name:      service_name,
          version:   version,
          full_name: full_name,
          settings:  settings_schema,
          metadata:  metadata,
          actions:   actions_schema,
          events:    events_schema,
        }
      end
    end
  end
end
