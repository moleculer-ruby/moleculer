# frozen_string_literal: true

require_relative "./base_packet_behavior"

RSpec.describe Moleculer::Packets::Disconnect do
  let(:broker) do
    Moleculer::Broker.new(Moleculer::Configuration.new(
                            node_id:     "test1",
                            services:    [],
                            log_level:   "trace",
                            transporter: "fake://localhost",
                          ))
  end

  subject { Moleculer::Packets::Disconnect.new(broker.config, id: "1", success: true, data: {}) }

  include_examples "base packet"
end
