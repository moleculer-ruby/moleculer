# frozen_string_literal: true

require "uri"
require "logger"
require "timeout"
require "forwardable"

require_relative './registry'

module Moleculer
  ##
  # The Broker is the primary component of Moleculer. It handles actions, events, and communication with remote nodes. Only a single broker should
  # be run for any given process, and it is automatically started when Moleculer::start or Moleculer::run is called.
  class Broker
    attr_reader :logger

    def initialize
      @registry = Registry.new(self)
      @logger   = Moleculer.create_logger("BROKER")
    end

    def start
      logger.info "starting"
      register_local_services
    end

    private

    def register_local_services
      logger.info "registering #{Moleculer.services.length} local services"
      Moleculer.services.each do |service|
        register_service(service)
      end
    end

    def register_service(service)
      @registry.register_local_service(service)
    end
  #   include Forwardable
  #
  #   ##
  #   # Thrown when a request times out.
  #   class RequestTimeoutError < Timeout::Error
  #     def initialize(request)
  #       super("An error occurred executing action '#{request.action}', no response was received within #{Moleculer.timeout} seconds")
  #     end
  #   end
  #
  #   include Concurrent::Async
  #   attr_reader :node_id, :transporter, :logger, :namespace, :services
  #
  #   ##
  #   # @param options [Hash] broker options
  #   # @option options [string] :namespace Namespace of nodes to segment your nodes on the same network.
  #   # @option options [string] :node_id Unique node identifier. Must be unique in a namespace
  #   # @option options [string|Moleculer::Transporter] :transporter Transporter settings.
  #   def initialize(options)
  #     @namespace                 = options[:namespace]
  #     @logger                    = Logger.new(STDOUT)
  #     @node_id                   = options[:node_id] || "#{Socket.gethostname.downcase}-#{Process.pid}"
  #     @transporter               = Transporters.for(options[:transporter]).new(self, options[:transporter])
  #     @started                   = false
  #     @external_service_registry = ExternalServiceRegistry.new(self)
  #     @local_service_registry    = LocalServiceRegistry.new(self)
  #     @responses                 = Concurrent::Map.new
  #   end
  #
  #   ##
  #   # Starts the broker asynchronously. The broker will run until #stop is called.
  #   def start
  #     logger.info "Moleculer Ruby #{Moleculer::VERSION}"
  #     logger.info "Node ID: #{node_id}"
  #     logger.info "Transporter: #{transporter.name}"
  #     register_local_services
  #     transporter.async.connect
  #     subscribe_to_all_events
  #     publish_discover
  #     publish_info
  #     start_heartbeat
  #     @started = true
  #     self
  #   end
  #
  #   ##
  #   # Runs the broker synchronously. Blocks until the broker is stopped.
  #   def run
  #     start
  #     sleep 1 while @started
  #   end
  #
  #   # Stops the broker
  #   def stop
  #     @started = false
  #   end
  #
  #   ##
  #   # Blocks until the named service starts
  #   #
  #   # @param name [String] the name of the service to wait for
  #   # @param timeout [Integer] the maximum amount of time to wait. Defaults to Moleculer#timeout
  #   #
  #   # @raise [Moleculer::RequestTimeoutError] if the service is not registered within the timeout period
  #   #
  #   # @return [Moleculer::Broker] self
  #   def wait_for_service(name, timeout = Moleculer.timeout)
  #     @external_service_registry.wait_for_service(name, timeout)
  #     self
  #   end
  #
  #   ##
  #   # Creates a service from a class that includes the {Noleculer::Service} module.
  #   #
  #   # @param service [Moleculer::Service] creates and registers the service with the broker.
  #   def create_service(service)
  #     @local_service_registry.register(service)
  #     @local_service_registry
  #   end
  #
  #   def destroy_service(name); end
  #
  #   ##
  #   # Calls an action on a remote service. This is load balanced, and will dispatch the action call in rotation to
  #   # any node has the service registered.
  #   def call(action_name, params, options = {}, &block)
  #     request = Packets::Request.new(
  #       action: action_name,
  #       params: params,
  #       meta: options[:meta] || {},
  #       metrics: false,
  #       timeout: Moleculer.timeout,
  #       level: 1,
  #       stream: false
  #     )
  #     publish_call(request)
  #     return async.handle_response(request, &block) if block_given?
  #
  #     handle_response(request) { |_, response| response }
  #   end
  #
  #   def mcall; end
  #
  #   def emit(event_name, payload, groups=[])
  #     event = Packets::Event.new(
  #       event: event_name,
  #       data: payload,
  #       groups: [],
  #     )
  #     nodes = @external_service_registry.events[event_name]
  #     if nodes
  #       nodes.each do |node|
  #         event.target_node = node.name
  #         @transporter.publish(event)
  #       end
  #     end
  #   end
  #
  #   def broadcast(event_name, payload, groups); end
  #
  #   def broadcast_local(event_name, payload, groups); end
  #
  #   def ping(node_id, timeout); end
  #
  #   def handle_response(request)
  #     response = nil
  #     Timeout.timeout(Moleculer.timeout) do
  #       sleep 0.01 until response = @responses.fetch(request.id, nil)
  #     end
  #     @responses.delete(request.id)
  #     yield request, response
  #   rescue Timeout::Error => e
  #     error = RequestTimeoutError.new(request)
  #     error.set_backtrace(e.backtrace)
  #     @logger.error(RequestTimeoutError.new(request))
  #     raise error
  #   end
  #
  #   private
  #
  #   def publish_call(request)
  #     node = @external_service_registry.get_node_for_action(request.action)
  #     request.target_node = node
  #     @transporter.publish(request)
  #   end
  #
  #   def start_heartbeat
  #     Concurrent::TimerTask.new(execution_interval: 1, run_now: true) do
  #       publish_heartbeat
  #     end.execute
  #   end
  #
  #   def publish_heartbeat
  #     @transporter.publish(Packets::Heartbeat.new(
  #                            sender: @node_id,
  #                            cpu: 0
  #                          ))
  #   end
  #
  #   def publish_discover
  #     @transporter.publish(Packets::Discover.new(
  #                            sender: @node_id
  #                          ))
  #   end
  #
  #   def publish_info
  #     @transporter.publish(@local_service_registry.to_info)
  #   end
  #
  #   def publish_response(packet)
  #     @transporter.publish(packet)
  #   end
  #
  #   def register_local_services
  #     logger.info "Registering #{Moleculer.services.length} services"
  #     Moleculer.services.each { |service| create_service(service) }
  #   end
  #
  #   def subscribe_to_all_events
  #     subscribe_to_disconnect
  #     subscribe_to_discover
  #     subscribe_to_events
  #     subscribe_to_info
  #     subscribe_to_ping
  #     subscribe_to_pong
  #     subscribe_to_requests
  #     subscribe_to_responses
  #     subscribe_to_targeted_discover
  #     subscribe_to_targeted_info
  #     subscribe_to_targeted_ping
  #   end
  #
  #   def subscribe_to_balanced_events(event)
  #     logger.debug "setting up EVENTB subscription for '#{event}'"
  #     transporter.subscribe("MOL.EVENTB.#{event}", Packets::Event) do
  #     end
  #   end
  #
  #   def subscribe_to_balanced_requests(action)
  #     logger.debug "setting up REQB subscription for action '#{action}'"
  #     transporter.subscribe("MOL.REQB.#{action}", Packets::Request) do
  #     end
  #   end
  #
  #   def subscribe_to_disconnect
  #     logger.debug "setting up DISCONNECT subscription"
  #     transporter.subscribe("MOL.DISCONNECT", Packets::Disconnect) do
  #     end
  #   end
  #
  #   def subscribe_to_discover
  #     logger.debug "setting up DISCOVER subscription"
  #     transporter.subscribe("MOL.DISCOVER", Packets::Discover) do
  #     end
  #   end
  #
  #   def subscribe_to_events
  #     logger.debug "setting up EVENT subscription"
  #     transporter.subscribe("MOL.EVENT.#{node_id}", Packets::Event) do |packet|
  #       @local_service_registry.execute_event(packet)
  #     end
  #   end
  #
  #   def subscribe_to_info
  #     logger.debug "setting up INFO subscription"
  #     transporter.subscribe("MOL.INFO", Packets::Info) do |packet|
  #       @external_service_registry.process_info_packet(packet)
  #     end
  #   end
  #
  #   def subscribe_to_ping
  #     logger.debug "setting up PING subscription"
  #     transporter.subscribe("MOL.PING", Packets::Ping) do
  #     end
  #   end
  #
  #   def subscribe_to_pong
  #     logger.debug "setting up PONG subscription"
  #     transporter.subscribe("MOL.PONG", Packets::Pong) do
  #     end
  #   end
  #
  #   def subscribe_to_requests
  #     logger.debug "setting up REQ subscription"
  #     transporter.subscribe("MOL.REQ.#{node_id}", Packets::Request) do |packet|
  #       # TODO: should only accept a single packet param
  #       response = @local_service_registry.execute_action(packet.action, packet)
  #       publish_response(response)
  #     end
  #   end
  #
  #   def subscribe_to_responses
  #     logger.debug "setting up RES subscription"
  #     transporter.subscribe("MOL.RES.#{node_id}", Packets::Response) do |packet|
  #       @responses.put_if_absent(packet.id, packet)
  #     end
  #   end
  #
  #   def subscribe_to_targeted_discover
  #     logger.debug "setting up targeted DISCOVER subscription"
  #     transporter.subscribe("MOL.DISCOVER.#{node_id}", Packets::Discover) do
  #       publish_info
  #     end
  #   end
  #
  #   def subscribe_to_targeted_ping
  #     logger.debug "setting up targeted PING subscription"
  #     transporter.subscribe("MOL.PING.#{node_id}", Packets::Ping) do
  #     end
  #   end
  #
  #   def subscribe_to_targeted_info
  #     logger.debug "setting up targeted INFO subscription"
  #     transporter.subscribe("MOL.INFO.#{node_id}", Packets::Info) do |packet|
  #       @external_service_registry.process_info_packet(packet)
  #     end
  #   end
  end
end
