# frozen_string_literal: true

module Moleculer
  module Transporters
    ##
    # Base transporter class
    class Base
      def connect
        raise NotImplementedError
      end

      def disconnect
        raise NotImplementedError
      end

      def subscribe
        raise NotImplementedError
      end

      def subscribe_balanced_request
        raise NotImplementedError
      end

      def subscribe_balanced_event
        raise NotImplementedError
      end

      def send
        raise NotImplementedError
      end
    end
  end
end
