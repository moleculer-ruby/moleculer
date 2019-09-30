# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "local_service"
require_relative "remote_service"

module IntegrationHelpers
  class PseudoBroker
    extend Forwardable

    def initialize(rspec, broker)
      @rspec  = rspec
      @broker = broker
    end

    def call(action_name, params, meta: {}, node_id: nil, timeout: Moleculer.config.timeout)
      @broker.call(action_name, params, meta: meta, node_id: node_id, timeout: timeout)
    end

    def start
      @broker.start
    end

    def stop
      # @broker.stop
    end
  end

  def remote
    @remote
  end

  def local
    @local
  end

  alias broker local

  def create_broker(*services)
    Moleculer::Broker.new(Moleculer::Configuration.new(
                            node_id:     SecureRandom.hex(5),
                            services:    services,
                            transporter: "fake://localhost",
                            log_file:    STDOUT,
                          ))
  end
end

RSpec.configure do |c|
  c.include IntegrationHelpers

  c.before :all do
    @remote = create_broker(RemoteService)
    @local  = create_broker(LocalService)
    @remote.start
    @local.start
    @local.wait_for_services("local", "remote")
  end

  c.after :all do
    @remote.stop
    @local.stop
  end
end
