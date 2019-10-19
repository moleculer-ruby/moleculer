# frozen_string_literal: true

require_relative "./base_packet_behavior"

RSpec.describe Moleculer::Packets::Info do
  let(:config) do
    Moleculer::Configuration.new(
      node_id:     "test1",
      services:    [],
      log_level:   "trace",
      transporter: "fake://localhost",
      log_file:    "test",
    )
  end

  subject do
    Moleculer::Packets::Info.new(config,
                                 services: [],
                                 ip_list:  [],
                                 hostname: "test",
                                 client:   { version: "1", type: "ruby", lang_version: "2" })
  end

  include_examples "base packet"

  describe "#to_hash" do
    it "does not include the log file" do
      expect(subject.to_h[:config][:log_file]).to be_nil
    end
  end
end
