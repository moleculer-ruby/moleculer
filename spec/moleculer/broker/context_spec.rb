# frozen_string_literal: true

RSpec.describe Moleculer::Broker::Context do
  let(:broker) { double(Moleculer::Broker::Base) }
  let(:endpoint) { double(Moleculer::Service::Action, broker: broker) }
  subject { Moleculer::Broker::Context.new(endpoint: endpoint, options: {}) }


  describe "#emit" do
    let(:broker) { double(Moleculer::Broker::Base, emit: true) }
    let(:endpoint) { double(Moleculer::Service::Event, broker: broker) }

    it "delegates the call to the broker" do
      subject.emit("test", { test: "test" }, option: "options")
      expect(broker).to have_received(:emit).with("test", { test: "test" }, option: "options")
    end
  end

  describe "#broadcast" do
    let(:broker) { double(Moleculer::Broker::Base, broadcast: true) }
    let(:endpoint) { double(Moleculer::Service::Event, broker: broker) }

    it "delegates the call to the broker" do
      subject.broadcast("test", { test: "test" }, option: "options")
      expect(broker).to have_received(:broadcast).with("test", { test: "test" }, option: "options")
    end
  end

  describe "#call" do
    let(:broker) { double(Moleculer::Broker::Base, call: true) }
    let(:endpoint) { double(Moleculer::Service::Event, broker: broker) }


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


    context "#parent_id" do
      context

    end
  end

  describe "#level" do
    it "correctly responds to level and sets the default to 1" do
      expect(subject.level).to eq(1)
    end
  end

  describe "#parent_id" do
    context "with parent_context" do
      let(:parent_context) { Moleculer::Broker::Context.new(endpoint: endpoint, options: {}) }
      subject { Moleculer::Broker::Context.new(endpoint: endpoint, options: {}, parent_context: parent_context) }

      it "returns the parent context id" do
        expect(subject.parent_id).to eq(parent_context.id)
      end
    end

    context "without a parent context" do
      it "returns nil" do
        expect(subject.parent_id).to be_nil
      end
    end
  end
end
