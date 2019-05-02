# frozen_string_literal: true

require "socket"

module Moleculer
  ##
  # Nodes are a representation of communicating apps within the same event bus.
  # A node is something that emits/listens to events within the bus and
  # communicates accordingly.
  class Node
    class << self
      def from_remote_info(info_packet)
        new(
          services: info_packet.services,
          node_id:  info_packet.sender,
        )
      end
    end

    attr_reader :id,
                :services

    def initialize(options = {})
      @id       = options.fetch(:node_id)
      @local    = options.fetch(:local, false)
      @hostname = options.fetch(:hostname, Socket.gethostname)

      svcs = options.fetch(:services)
      # TODO: move this up to from_remote_info
      svcs.map! { |service| Service.from_remote_info(service, self) } if svcs.first.is_a? Hash
      @services = Hash[svcs.map { |s| [s.service_name, s] }]
    end

    def register_service(service)
      @services[service.name] = service
    end

    ##
    # @return [Hash] returns a key, value mapping of available actions on this node
    # TODO: refactor this into a list object
    def actions
      unless @actions
        @actions = {}

        @services.each_value { |s| s.actions.each { |key, value| @actions[key] = value } }
      end
      @actions
    end

    ##
    # @return [Hash] returns a key value mapping of events on this node
    # TODO: refactor this into a list object
    def events
      unless @events
        @events = {}
        @services.each_value do |s|
          s.events.each do |key, value|
            @events[key] ||= []
            @events[key] << value
          end
        end
      end
      @events
    end

    ##
    # @return [Time] the time of the last heartbeat, or Time#now if the node is local.
    def last_heartbeat_at
      return Time.now if local?

      @last_heartbeat_at || Time.now
    end

    ##
    # Updates the last heartbeat to Time#now
    def beat
      @last_heartbeat_at = Time.now
    end

    def local?
      @local
    end

    def as_json
      {
        sender:   @id,
        config:   {},
        seq:      1,
        ipList:   [],
        hostname: @hostname,
        services: @services.values.map(&:as_json),
        client:   client_attrubutes,
      }
    end

    private

    def client_attrubutes
      {
        type:         "Ruby",
        version:      Moleculer::VERSION,
        lang_version: RUBY_VERSION,
      }
    end
  end
end
