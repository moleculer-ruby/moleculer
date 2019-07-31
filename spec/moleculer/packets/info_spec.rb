# frozen_string_literal: true

require_relative "./base_packet_behavior"

RSpec.describe Moleculer::Packets::Info do
  let(:broker) do
    Moleculer::Broker.new(Moleculer::Configuration.new(
                            node_id:     "test1",
                            services:    [],
                            log_level:   "trace",
                            transporter: "fake://localhost",
                          ))
  end

  subject do
    Moleculer::Packets::Info.new(broker.config,
                                 services: [],
                                 ip_list:  [],
                                 hostname: "test",
                                 client:   { version: "1", type: "ruby", lang_version: "2" })
  end

  include_examples "base packet"
end
