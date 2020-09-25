# frozen_string_literal: true

RSpec.describe Moleculer::Registry::Node do
  let(:service) do
    Class.new(Moleculer::Service::Base) do
      service_name "local-service"

      action "local-action", method: :local_action
    end
  end

  subject do
    Moleculer::Node.new(double("broker"), id: "node")
  end

  describe "::from_info_packet" do
    subject { Moleculer::Registry::Node }

    let(:schema) do
      {
        ver:      "4",
        sender:   "node-1",
        services: {
        },
        config:   {},
        hostname: "node.host",
        ip_list:  ["127.0.0.1"],
        metadata: {},
      }
    end

    it "should create a node from the provided schema" do
    end
  end

  describe "#schema" do
    it "generates a valid schema" do
      expect(subject.schema).to include(
        ip_list:  Moleculer::Utils.get_ip_list,
        client:   {
          type:         "ruby",
          version:      Moleculer::VERSION,
          lang_version: RUBY_VERSION,
        },
        seq:      0,
        services: array_including(
          hash_including(
            name: "local-service",
          ),
        ),
      )
    end
  end

  describe "#actions" do
    it "returns all of the actions for the node" do
      expect(subject.actions).to include("local-service.local-action" => instance_of(Moleculer::Service::Action))
    end
  end
end
