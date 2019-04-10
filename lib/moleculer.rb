require "concurrent"
require "securerandom"
require "socket"
require "ougai"

require "moleculer/broker"
require "moleculer/context"
require "moleculer/service"
require "moleculer/support"
require "moleculer/version"
require "moleculer/node"
require "moleculer/serializers"
require "moleculer/packets"
require "moleculer/configuration"

# Moleculer is a fast, modern and powerful microservices framework for originally written for
# {Node.js}[https://nodejs.org/en/]. It helps you to build efficient, reliable & scalable services. Moleculer provides
# many features for building and managing your microservices.
#
# This is a Ruby port of the Moleculer protocol, allowing a seamless mesh between NodeJS service nodes, Ruby service
# nodes, and nodes in other
# {supported languages}[https://github.com/moleculerjs/awesome-moleculer#polyglot-implementations].
module Moleculer
  extend self
  PROTOCOL_VERSION = "3".freeze

  # @return [Symbol] the service prefix. When used will prefix all services name with `<service_prefix>.`, defaults
  #                  to `nil`
  attr_accessor :service_prefix

  ##
  # @!attribute broker [r]
  #
  # @return [Moleculer::Broker] the Moleculer Broker instance. Only one broker can exist per node.
  def broker
    @broker ||= Broker.new(config)
  end

  ##
  # Calls the given action. This method will block until the timeout is hit (default 5 seconds) or the action returns
  # a response
  #
  # @param action [Symbol] the name of the action to call
  # @param params [Hash] params to pass to the action
  # @param kwargs [Hash] call options (see Moleculer::Broker#call)
  #
  # @return [Hash] the request response
  def call(action, params = {}, **kwargs)
    broker.ensure_running
    return broker.call(action.to_s, kwargs) if params.empty?

    broker.call(action.to_s, params, kwargs)
  end

  def config
    @config ||= Configuration.new
  end

  ##
  # Allows configuration of moleculer. For more information on configuration see the [Readme](/index.html)
  #
  # @yield [self]
  def configure
    yield config
  end

  ##
  # Emits the given event to the Moleculer network.
  #
  # @param event [String] the name of the event
  # @param data [Hash] the data related to the event
  def emit(event, data)
    broker.ensure_running
    broker.emit(event, data)
  end

  ##
  # Runs the moleculer broker. This is synchronous and blocks.
  def run
    broker.run
  end

  ##
  # Starts the moleculer broker. This is asynchronous and does not block.
  def start
    broker.start
  end

  ##
  # Stops the moleculer broker.
  def stop
    broker.stop
  end

  ##
  # Blocks the processes until the requested services have been registered on the network.
  #
  # @param services [Array<String>] a list of service to wait for.
  #
  # @example
  #   Moleculer.wait_for_services("some.service", "someother.service")
  def wait_for_services(*services)
    broker.wait_for_services(*services)
  end
end
