# frozen_string_literal: true

RSpec.describe Moleculer::Broker::Context do
  describe "#emit" do
    let(:broker) { double(Moleculer::Broker::Base, emit: true) }
    let(:endpoint) { double(Moleculer::Service::Event, broker: broker) }

    subject { Moleculer::Broker::Context.new(endpoint: endpoint, options: {}) }

    it "delegates the call to the broker" do
      subject.emit("test", { test: "test" }, option: "options")
      expect(broker).to have_received(:emit).with("test", { test: "test" }, option: "options")
    end
  end

  describe "#broadcast" do
    let(:broker) { double(Moleculer::Broker::Base, broadcast: true) }
    let(:endpoint) { double(Moleculer::Service::Event, broker: broker) }

    subject { Moleculer::Broker::Context.new(endpoint: endpoint, options: {}) }

    it "delegates the call to the broker" do
      subject.broadcast("test", { test: "test" }, option: "options")
      expect(broker).to have_received(:broadcast).with("test", { test: "test" }, option: "options")
    end
  end

  describe "#call" do
    let(:broker) { double(Moleculer::Broker::Base, call: true) }
    let(:endpoint) { double(Moleculer::Service::Event, broker: broker) }

    subject { Moleculer::Broker::Context.new(endpoint: endpoint, options: {}) }

    context "no timeout" do
      it "calls through the broker passing a new parent context" do
        subject.call("test", { foo: "bar" }, bar: "foo")
        expect(broker).to have_received(:call).with("test", { foo: "bar" }, bar: "foo", parent_context: subject)
      end
    end

    context "with timeout" do
      it "adds the timeout to the call options" do
        subject.execute do
          subject.call("test", { foo: "bar" }, bar: "foo", timeout: 10)
        end
        expect(broker).to have_received(:call).with("test", { foo: "bar" }, bar: "foo", parent_context: subject, timeout: 10)
      end
    end
  end
end
