# frozen_string_literal: true

require "logger"
require "forwardable"
require "dry/initializer"
require "dry/types"
require "console"

require_relative "moleculer/types"
require_relative "moleculer/logger"
require_relative "moleculer/version"
require_relative "moleculer/registry"
require_relative "moleculer/broker"
require_relative "moleculer/packet"
require_relative "moleculer/serializers"
