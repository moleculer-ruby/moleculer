module Moleculer
  module Service
    ##
    # @abstract
    class Abstract
      ##
      # @return [Hash] a hash of all the action for this service, where the key is the action name
      def actions
        @actions ||= {}
      end

      ##
      # @return [Hash] a hash of all the events for this service, where the key is the event name
      def events
        @events ||= {}
      end
    end
  end
end