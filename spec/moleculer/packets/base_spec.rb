# frozen_string_literal: true

require_relative "./base_packet_behavior"

RSpec.describe Moleculer::Packets::Base do
  let(:broker) do
    Moleculer::Broker.new(Moleculer::Configuration.new(
                            node_id:     "test1",
                            services:    [],
                            log_level:   "trace",
                            transporter: "fake://localhost",
                          ))
  end

  subject { Moleculer::Packets::Base.new(broker.config) }

  include_examples "base packet"

  describe "overrides" do
    subject { Moleculer::Packets::Base.new(broker.config, ver: "4", sender: "not-node") }
    describe "#ver" do
      it "uses data[:ver]" do
        expect(subject.ver).to eq "4"
      end
    end

    describe "#sender" do
      it "uses data[:sender]" do
        expect(subject.sender).to eq "not-node"
      end
    end
  end
end
