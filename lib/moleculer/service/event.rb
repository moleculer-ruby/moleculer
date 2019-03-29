require_relative "../errors/invalid_action_response"
require_relative "../support"
module Moleculer
  module Service
    ##
    # Represents an action
    class Event
      include Support

      # @!attribute [r] name
      #   @return [String] the name of the action
      attr_reader :name

      def initialize(name, service, method, options = {})
        @name    = name
        @service = service
        @method  = method
        @service = service
        @options = options
      end

      def execute(data, options)
        @service.new.public_send(@method, data, options)
      end

      def node
        @service.node
      end

      def as_json
        {
          name:    "#{@service.service_name}.#{name}",
          rawName: name,
          cache:   HashUtil.fetch(@options, :cache, false),
          metrics: {
            params: false,
            meta:   true,
          },
        }
      end
    end
  end
end
