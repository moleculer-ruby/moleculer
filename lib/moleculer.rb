# frozen_string_literal: true

require "semantic_logger"

require "ext/hash"
require "ext/string"

require "moleculer/version"
require "moleculer/packets"
require "moleculer/node"
require "moleculer/service"
require "moleculer/context"
require "moleculer/transporters"
require "moleculer/serializers"
require "moleculer/broker"

module Moleculer
  PROTOCOL_VERSION = "4.0"
end
