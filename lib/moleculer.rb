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

  attr_writer :log_level,
              :heartbeat_interval,
              :serializer,
              :timeout,
              :transporter

  # @return [Symbol] the service prefix. When used will prefix all services name with `<service_prefix>.`, defaults
  #                  to `nil`
  attr_accessor :service_prefix

  ##
  # @!attribute broker [r]
  #
  # @return [Moleculer::Broker] the Moleculer Broker instance. Only one broker can exist per node.
  def broker
    @broker ||= Broker.new
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

  ##
  # Allows configuration of moleculer. For more information on configuration see the [Readme](/index.html)
  #
  # @yield [self]
  def config
    yield self
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


  # @!attribute log_level [w]
  #   @return [Symbol] the Moleculer log_level. Defaults to `:debug`

  ##
  # @return [Ougai::Logger] the logging instance for this node. Log level is set to `:debug` by default.
  def logger
    unless @logger
      @logger           = Ougai::Logger.new(@log || STDOUT)
      @logger.formatter = Ougai::Formatters::Readable.new("MOL")
      @logger.level     = @log_level || :debug
    end
    @logger
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
    @broker.wait_for_services(*services)
  end

  # CONFIGURATION

  ##
  # @!attribute heartbeat_interval [r|w]
  #   @return [Integer] the interval in seconds in which to send M
  def heartbeat_interval
    @heartbeat_interval ||= 5
  end

  ##
  # @!attribute node_id [r\w]
  #   @return [String] the Moleculer node id for this running process. Moleculer will automatically append the Process
  #                    PID to whatever `node_id` is set to, example: `node_id-3232`. Defaults to
  #                    `Socket.gethostname.downcase`
  def node_id
    self.node_id = "#{Socket.gethostname.downcase}-#{Process.pid}" unless @node_id
    @node_id
  end

  def node_id=(_id)
    @node_id = "#{@node_id}-#{Process.pid}"
  end

  # @!attribute serializer [r|w]
  #   @return [Symbol] the serialization to use. See [Serializers](https://moleculer.services/docs/0.13/networking.html#Serialization)
  def serializer
    @serializer ||= :json
  end

  ##
  # @!attribute services [r]
  #   @return [Array<Moleculer::Service>] services to load. To add services push the services you wish to load to the
  #                                       array.
  #
  def services
    @services ||= []
  end

  ##
  # @!attribute timeout [r|w]
  #   @return [Integer] the timeout with which to wait for requests to remote nodes.
  def timeout
    @timeout ||= 5
  end

  ##
  # @!attribute transporter [r|w]
  #   @return [String] the fully qualified url for the transporter. See [Transporters](https://moleculer.services/docs/0.13/networking.html#Transporters)
  #                    for more details.
  def transporter
    @transporter || "redis://localhost"
  end
end
