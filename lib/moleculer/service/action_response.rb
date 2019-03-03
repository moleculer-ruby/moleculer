module Moleculer
  module Service
    ##
    # Represents an action response
    class ActionResponse

      ##
      # @param response [Hash] the response from executing the action
      # @param context [Moleculer::Context] the context fo the action
      def initialize(response, context)
        @response = response
        @context  = context
      end
    end
  end
end
