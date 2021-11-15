# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Moleculer::Packets::Info do
  describe "::TOPIC" do
    it "should be 'INFO'" do
      expect(Moleculer::Packets::Info::TOPIC).to eq("INFO")
    end
  end

  describe "::from_node" do
    let(:node) do
      double(Moleculer::Node,
             to_info: {
               sender:      "sender",
               hostname:    "hostname",
               metadata:    {
                 some: "metadata",
               },
               instance_id: "instance_id",
               ip_list:     ["ip_list"],
               client:      {
                 lang_version: "3.0.2",
                 type:         "ruby",
                 version:      "0.4.0",
               },
               services:    {
                 "some" => "service",
               },
               seq:         0,
             })
    end

    it "should return a Info packet" do
      # noinspection RubyMismatchedArgumentType
      packet = Moleculer::Packets::Info.from_node(node)

      expect(packet).to be_a(Moleculer::Packets::Info)
      expect(packet.sender).to eq("sender")
      expect(packet.hostname).to eq("hostname")
      expect(packet.metadata).to eq({
                                      some: "metadata",
                                    })
      expect(packet.instance_id).to eq("instance_id")
      expect(packet.client).to eq({
                                    type:         "ruby",
                                    version:      "0.4.0",
                                    lang_version: "3.0.2",
                                  })
      expect(packet.services).to eq({
                                      "some" => "service",
                                    })
      expect(packet.ip_list).to eq(["ip_list"])
      expect(packet.seq).to eq(0)
    end
  end

  describe "::new" do
    # a node hash keyed by strings instead of symbols
    let(:node) do
      {
        "sender"     => "sender",
        "hostname"   => "hostname",
        "metadata"   => {
          "some" => {
            "deep" => "metadata",
          },
        },
        "instanceID" => "instance_id",
        "ipList"     => ["ip_list"],
        "client"     => {
          "type"        => "ruby",
          "version"     => "0.4.0",
          "langVersion" => "3.0.4",
        },
        "services"   => {
          "some" => "service",
        },
        "seq"        => 0,
      }
    end

    it "should parse the data correctly" do
      packet = described_class.new(node)

      expect(packet).to be_a(Moleculer::Packets::Info)
      expect(packet.sender).to eq("sender")
      expect(packet.hostname).to eq("hostname")
      expect(packet.metadata).to eq({
                                      some: {
                                        deep: "metadata",
                                      },
                                    })
      expect(packet.instance_id).to eq("instance_id")
      expect(packet.client).to eq({
                                    lang_version: "3.0.4",
                                    type:         "ruby",
                                    version:      "0.4.0",
                                  })
      expect(packet.services).to eq({
                                      "some" => "service",
                                    })
      expect(packet.ip_list).to eq(["ip_list"])
      expect(packet.seq).to eq(0)
    end
  end

  describe "#to_h" do
    it "should return a hash representing the info packet" do
      packet = described_class.new(
        sender:      "sender",
        hostname:    "hostname",
        metadata:    {
          some: "metadata",
        },
        instance_id: "instance_id",
        client:      {
          type:         "ruby",
          version:      "0.4.0",
          lang_version: "3.0.2",
        },
        services:    {
          "some" => "service",
        },
        ip_list:     ["ip_list"],
        seq:         0,
      )

      expect(packet.to_h).to eq({
                                  ver:         Moleculer::PROTOCOL_VERSION,
                                  sender:      "sender",
                                  hostname:    "hostname",
                                  metadata:    {
                                    some: "metadata",
                                  },
                                  instance_id: "instance_id",
                                  client:      {
                                    type:         "ruby",
                                    version:      "0.4.0",
                                    lang_version: "3.0.2",
                                  },
                                  services:    {
                                    "some" => "service",
                                  },
                                  ip_list:     ["ip_list"],
                                  seq:         0,
                                })
    end
  end
end
