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

  subject { Moleculer::Node.new(id: "test", services: [service1, service2]) }

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
end
