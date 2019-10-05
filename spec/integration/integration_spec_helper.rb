# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "local_service"
require_relative "remote_service"

module IntegrationHelpers
  def remote
    @remote
  end

  def local
    @local
  end
  alias broker local

  def create_broker(node_id, *services)
    Moleculer::Broker.new(Moleculer::Configuration.new(
                            node_id:     node_id,
                            services:    services,
                            transporter: "fake://localhost",
                            log_file:    STDOUT,
                          ))
  end
end

RSpec.configure do |c|
  c.include IntegrationHelpers

  c.before :all do
    @remote = create_broker("remote", RemoteService)
    @local  = create_broker("local", LocalService)
    @remote.start
    @local.start
    @local.wait_for_services("local", "remote")
  end

  c.after :all do
    @remote.stop
    @local.stop
  end
end
