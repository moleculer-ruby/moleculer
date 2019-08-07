# frozen_string_literal: true

require_relative "./base_packet_behavior"

RSpec.describe Moleculer::Packets::Req do
  let(:broker) do
    Moleculer::Broker.new(Moleculer::Configuration.new(
                            node_id:     "test1",
                            services:    [],
                            log_level:   "trace",
                            transporter: "fake://localhost",
                          ))
  end

  let(:node) { double("node", id: 1) }

  subject do
    Moleculer::Packets::Req.new(broker.config,
                                node:   node,
                                id:     SecureRandom.uuid,
                                action: "test",
                                meta:   {},
                                params: {})
  end

  include_examples "base packet"
end
