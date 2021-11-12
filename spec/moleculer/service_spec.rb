# frozen_string_literal: true

require "spec_helper"

RSpec.describe Moleculer::Service do
  context "defined service" do
    subject do
      Class.new(described_class) do
        name "test"

        action "add", :add
        event "an_event", :an_event

        def add(context)
          context.params["a"] + context.params["b"]
        end

        def an_event(_context)
          true
        end
      end.new
    end

    describe "#name" do
      it "returns the service name" do
        expect(subject.name).to eq("test")
      end
    end

    describe "#version" do
      it "returns the service version" do
        expect(subject.version).to eq(1)
      end
    end


    describe "#actions" do
      let(:context) { double(Moleculer::Context, params: { "a" => 1, "b" => 2 }) }
      it "returns the actions" do
        expect(subject.actions["test.add"]).to be_a(Moleculer::Service::Action)
      end

      it "the returned Proc calls #call_action" do
        expect(subject.actions["test.add"].call(context)).to eq(3)
      end
    end

    describe "#events" do
      let(:context) { double(Moleculer::Context, params: { "a" => 1, "b" => 2 }) }
      it "returns the events" do
        expect(subject.events["an_event"]).to be_a(Moleculer::Service::Event)
      end

      it "the returned Proc calls #call_event" do
        expect(subject).to receive(:an_event).with(context)
        subject.events["an_event"].call(context)
      end
    end
  end
end
