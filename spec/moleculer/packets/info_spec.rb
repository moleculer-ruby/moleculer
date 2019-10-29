# frozen_string_literal: true

require_relative "./base_packet_behavior"

RSpec.describe Moleculer::Packets::Info do
  let(:test_service) do
    Class.new(Moleculer::Service::Base) do
      action :test, :test

      def test; end
    end
  end

  let(:config) do
    Moleculer::Configuration.new(
      node_id:     "test1",
      transporter: "fake://localhost",
      log_file:    "test",
    )
  end

  let(:valid_hash) do
    Moleculer::Support::HashUtil::HashWithIndifferentAccess.from_hash(
      services: [],
      ipList:   [],
      hostname: "test",
      client:   {
        version:     "1",
        type:        "ruby",
        langVersion: "2",
      },
      config:   {
        heartbeatInterval: 5,
        logLevel:          :debugo,
        transporter:       "fake://localhost",
        serializer:        :json,
        servicePrefix:     nil,
        timeout:           5,
        nodeId:            "test1",
      },
    ).to_camelized_hash
  end

  subject do
    Moleculer::Packets::Info.new(config,
                                 services: [],
                                 ip_list:  [],
                                 hostname: "test",
                                 client:   { version: "1", type: "ruby", lang_version: "2" })
  end

  include_examples "base packet"

  describe "#to_h" do
    it "does not include the log file" do
      expect(subject.to_h["config"]["logFile"]).to be_nil
    end

    it "includes the client config" do
      expect(subject.to_h["client"]).to include(
        "type"        => "ruby",
        "version"     => "1",
        "langVersion" => "2",
      )
    end
  end
end
