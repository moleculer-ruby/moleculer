# frozen_string_literal: true

require_relative "default_options"
require_relative "controls"
require_relative "events"
require_relative "actions"
require_relative "logger"
require_relative "serializer"
require_relative "transporter"
require_relative "registry"
require_relative "transit"


module Moleculer
  module Broker
    ##
    # The Moleculer service broker
    class Base
      include Logger
      include Controls
      include Events
      include Actions
      include Transit
      include Transporter
      include Serializer
      include Registry
      include DefaultOptions
    end
  end
end
