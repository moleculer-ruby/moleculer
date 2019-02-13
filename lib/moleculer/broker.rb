# frozen_string_literal: true

require "uri"
require "logger"


require_relative "./packets"
require_relative "./transporters"
require_relative "./version"

module Moleculer
  class Broker
    attr_reader :node_id, :transporter, :logger, :namespace, :services

    def initialize(options)
      @namespace   = options[:namespace]
      @logger      = Logger.new(STDOUT)
      @node_id     = options[:node_id]
      @transporter = Transporters.for(options[:transporter]).new(self, options[:transporter])
    end

    def start
      logger.info "Moleculer Ruby #{Moleculer::VERSION}"
      logger.info "Node ID: #{node_id}"
      logger.info "Transporter: #{transporter.name}"
      transporter.connect
      subscribe_to_all_events
      publish_discover
    end

    def run
      start
      transporter.join
    end

    private

    def publish_discover
      @transporter.publish(Packets::Discover.new({
        sender: @node_id
                                                 }))
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
      transporter.subscribe("MOL.INFO", Packets::Info) do

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
      transporter.subscribe("MOL.REQ.#{node_id}", Packets::Request) do

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

      end
    end


    def subscribe_to_targeted_ping
      logger.debug "setting up targeted PING subscription"
      transporter.subscribe("MOL.PING.#{node_id}", Packets::Ping) do

      end
    end


    def subscribe_to_targeted_info
      logger.debug "setting up targeted INFO subscription"
      transporter.subscribe("MOL.INFO.#{node_id}", Packets::Info) do

      end
    end

  end
end



