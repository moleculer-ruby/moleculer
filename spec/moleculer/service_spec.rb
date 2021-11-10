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

    describe "#call_action" do
      let(:context) { double(Moleculer::Context, params: { "a" => 1, "b" => 2 }) }
      it "calls the action" do
        expect(subject.call_action("add", context)).to eq(3)
      end
    end

    describe "#call_event" do
      let(:context) { double(Moleculer::Context, params: { "a" => 1, "b" => 2 }) }
      it "should call the event" do
        expect(subject).to receive(:an_event).with(context)
        subject.call_event("an_event", context)
      end
    end
  end
end
