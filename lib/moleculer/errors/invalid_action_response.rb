module Moleculer
  module Errors
    ##
    # Raised when an action does not return a hash
    class InvalidActionResponse < Exception
      def initialize(response)
        super "Action must return a Hash, instead it returned a #{response.class.name}"
      end
    end
  end
end
