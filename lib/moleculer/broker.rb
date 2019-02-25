# frozen_string_literal: true

require "uri"
require "logger"


require_relative "./packets"
require_relative "./transporters"
require_relative "./version"
require_relative "./external_service_registry"
require_relative "./local_service_registry"

module Moleculer
  ##
  # The Broker is the primary component of Moleculer. It handles actions, events, and communication with remote nodes.
  class Broker
    attr_reader :node_id, :transporter, :logger, :namespace, :services

    ##
    # @param options [Hash] broker options
    # @option options [string] :namespace Namespace of nodes to segment your nodes on the same network.
    # @option options [string] :node_id Unique node identifier. Must be unique in a namespace
    # @option options [string|Moleculer::Transporter] :transporter Transporter settings.
    def initialize(options)
      @namespace                 = options[:namespace]
      @logger                    = Logger.new(STDOUT)
      @node_id                   = options[:node_id]
      @transporter               = Transporters.for(options[:transporter]).new(self, options[:transporter])
      @started                   = false
      @external_service_registry = ExternalServiceRegistry.new(self)
      @local_service_registry    = LocalServiceRegistry.new(self)
    end

    ##
    # Starts the broker asynchronously.
    def start
      logger.info "Moleculer Ruby #{Moleculer::VERSION}"
      logger.info "Node ID: #{node_id}"
      logger.info "Transporter: #{transporter.name}"
      register_local_services
      transporter.async.connect
      subscribe_to_all_events
      publish_discover
      publish_info
      start_heartbeat
      @started = true
    end

    ##
    # Runs the broker synchronously
    def run
      start
      while @started
        sleep 1
      end
    end

    def stop
      @started = false
    end

    ##
    # Creates a service from a class that includes the {Noleculer::Service} module.
    #
    # @param service [Moleculer::Service] creates and registers the service with the broker.
    def create_service(service)
      @local_service_registry.register(service)
      @local_service_registry
    end

    def destroy_service(name)
    end

    def call(action_name, params, options)
    end

    def mcall
    end

    def emit(event_name, payload, groups)
    end

    def broadcast(event_name, payload, groups)
    end

    def broadcast_local(event_name, payload, groups)
    end

    def ping(node_id, timeout)
    end

    private

    def start_heartbeat
      heartbeat = Concurrent::TimerTask.new(execution_interval: 1, run_now: true) {
        publish_heartbeat
      }.execute
      heartbeat
    end

    def publish_heartbeat
      @transporter.publish(Packets::Heartbeat.new({
        sender: @node_id,
        cpu: 0
                                                  }))
    end

    def publish_discover
      @transporter.publish(Packets::Discover.new({
        sender: @node_id
                                                 }))
    end

    def publish_info
      @transporter.publish(@local_service_registry.to_info)
    end

    def publish_response(packet)
      @transporter.publish(packet)
    end

    def register_local_services
      logger.info "Registering #{Moleculer.services.length} services"
      Moleculer.services.each { |service| create_service(service) }
    end

    def subscribe_to_all_events
      subscribe_to_disconnect
      subscribe_to_discover
      subscribe_to_events
      subscribe_to_info
      subscribe_to_ping
      subscribe_to_pong
      subscribe_to_requests
      subscribe_to_responses
      subscribe_to_targeted_discover
      subscribe_to_targeted_info
      subscribe_to_targeted_ping
    end

    def subscribe_to_balanced_events(event)
      logger.debug "setting up EVENTB subscription for '#{event}'"
      transporter.subscribe("MOL.EVENTB.#{event}", Packets::Event) do

      end
    end


    def subscribe_to_balanced_requests(action)
      logger.debug "setting up REQB subscription for action '#{action}'"
      transporter.subscribe("MOL.REQB.#{action}", Packets::Request) do

      end
    end

    def subscribe_to_disconnect
      logger.debug "setting up DISCONNECT subscription"
      transporter.subscribe("MOL.DISCONNECT", Packets::Disconnect) do

      end
    end


    def subscribe_to_discover
      logger.debug "setting up DISCOVER subscription"
      transporter.subscribe("MOL.DISCOVER", Packets::Discover) do

      end
    end


    def subscribe_to_events
      logger.debug "setting up EVENT subscription"
      transporter.subscribe("MOL.EVENT.#{node_id}", Packets::Event) do

      end
    end

    def subscribe_to_info
      logger.debug "setting up INFO subscription"
      transporter.subscribe("MOL.INFO", Packets::Info) do |packet|
        @external_service_registry.process_info_packet(packet)
      end
    end

    def subscribe_to_ping
      logger.debug "setting up PING subscription"
      transporter.subscribe("MOL.PING", Packets::Ping) do

      end
    end

    def subscribe_to_pong
      logger.debug "setting up PONG subscription"
      transporter.subscribe("MOL.PONG", Packets::Pong) do

      end
    end

    def subscribe_to_requests
      logger.debug "setting up REQ subscription"
      transporter.subscribe("MOL.REQ.#{node_id}", Packets::Request) do |packet|
        response = @local_service_registry.execute_action(packet.action, packet)
        publish_response(response)
      end
    end

    def subscribe_to_responses
      logger.debug "setting up RES subscription"
      transporter.subscribe("MOL.RES.#{node_id}", Packets::Response) do

      end
    end

    def subscribe_to_targeted_discover
      logger.debug "setting up targeted DISCOVER subscription"
      transporter.subscribe("MOL.DISCOVER.#{node_id}", Packets::Discover) do
        publish_info
      end
    end


    def subscribe_to_targeted_ping
      logger.debug "setting up targeted PING subscription"
      transporter.subscribe("MOL.PING.#{node_id}", Packets::Ping) do
      end
    end


    def subscribe_to_targeted_info
      logger.debug "setting up targeted INFO subscription"
      transporter.subscribe("MOL.INFO.#{node_id}", Packets::Info) do |packet|
        @external_service_registry.process_info_packet(packet)
      end
    end

  end
end



