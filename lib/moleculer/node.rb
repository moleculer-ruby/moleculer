require "socket"

module Moleculer
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

        @services.values.each { |s| s.actions.each { |key, value| @actions[key] = value } }
      end
      @actions
    end

    ##
    # @return [Hash] returns a key value mapping of events on this node
    # TODO: refactor this into a list object
    def events
      unless @events
        @events = {}
        @services.values.map do |s|
          s.events.each do |key, value|
            @events[key] ||= []
            @events[key] << value
          end
        end
      end
      @events
    end

    def local?
      @local
    end

    def as_json
      {
        config:   {},
        seq:      1,
        ipList:   [],
        hostname: @hostname,
        services: @services.values.map(&:as_json),
        client:   {
          type:         "Ruby",
          version:      Moleculer::VERSION,
          lang_version: RUBY_VERSION,
        },
      }
    end
  end
end
