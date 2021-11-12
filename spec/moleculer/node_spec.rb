# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Moleculer::Node do
  let(:service1) do
    Class.new(Moleculer::Service::Base) do
      name "service_1"

      action "action_1", :action1
      event "event_1", :event1

      def action1(_ctx)
        true
      end

      def event1(_ctx)
        true
      end
    end
  end

  let(:service2) do
    Class.new(Moleculer::Service::Base) do
      name "service_2"

      action "action_2", :action2
      event "event_2", :event2

      def action2(_ctx)
        true
      end

      def event2(_ctx)
        true
      end
    end
  end

  subject do
    Moleculer::Node.new(
      id:          "test",
      hostname:    "test",
      instance_id: "id",
      services:    [service1, service2],
      client:      {
        type:         "ruby",
        version:      "0.4.0",
        lang_version: "3.0.2",
      },
    )
  end

  describe "#actions" do
    let(:context) { double(Moleculer::Context, params: { "a" => 1, "b" => 2 }) }
    it "returns all actions for all services" do
      expect(subject.actions).to be_a(Hash)
      expect(subject.actions["service_1.action_1"]).to_not be_nil
    end
  end

  describe "#events" do
    it "returns all events for all services" do
      expect(subject.events).to be_a(Hash)
      expect(subject.events["event_1"]).to_not be_nil
    end
  end

  describe "#call" do
    let(:context) { double(Moleculer::Context, params: { "a" => 1, "b" => 2 }) }
    it "calls the local endpoint if called" do
      # noinspection RubyMismatchedArgumentType
      expect(subject.call("service_1.action_1", context)).to be_truthy
    end
  end

  describe "#to_info" do
    it "returns a representation of the node as a hash" do
      expect(subject.to_info).to be_a(Hash)
      expect(subject.to_info[:sender]).to eq("test")
      expect(subject.to_info[:hostname]).to eq("test")
      expect(subject.to_info[:services]).to be_a(Array)
      expect(subject.to_info[:services].first).to be_a(Hash)
      expect(subject.to_info[:services].first[:name]).to eq("service_1")
      expect(subject.to_info[:client]).to be_a(Hash)
      expect(subject.to_info[:client][:type]).to eq("ruby")
      expect(subject.to_info[:client][:version]).to eq("0.4.0")
      expect(subject.to_info[:client][:lang_version]).to eq("3.0.2")
      expect(subject.to_info[:seq]).to eq(0)
    end
  end
end
