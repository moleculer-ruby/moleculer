# frozen_string_literal: true

require "spec_helper"

RSpec.describe Moleculer::Node do
  let(:service_1) do
    Class.new(Moleculer::Service) do
      name "service_1"

      action "action_1", :action_1
      event "event_1", :event_1

      def action_1(_ctx)
        true
      end

      def event_2(_ctx)
        true
      end
    end
  end

  let(:service_2) do
    Class.new(Moleculer::Service) do
      name "service_2"

      action "action_2", :action_2
      event "event_2", :event_2

      def action_2(_ctx)
        true
      end

      def event_2(_ctx)
        true
      end
    end
  end

  subject { Moleculer::Node.new({}, services: [service_1, service_2]) }
  describe "#actions" do
    let(:context) { double(Moleculer::Context, params: { "a" => 1, "b" => 2 }) }
    it "returns all actions for all services" do
      expect(subject.actions).to be_a(Hash)
      expect(subject.actions["service_1.action_1"]).to_not be_nil
    end
  end

  subject { Moleculer::Node.new({}, services: [service_1, service_2]) }
  describe "#events" do
    it "returns all events for all services" do
      expect(subject.events).to be_a(Hash)
      expect(subject.events["event_1"]).to_not be_nil
    end
  end

  describe "#call" do
    it "calls the local endpoint if called" do
      expect(subject.call("service_1.action_1", {})).to be_truthy
    end
  end
end
