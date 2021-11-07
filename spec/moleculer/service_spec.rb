# frozen_string_literal: true

require "spec_helper"

RSpec.describe Moleculer::Service do
  context "defined service" do
    subject do
      Class.new(described_class) do
        name "test"

        action "add", :add

        def add(context)
          context.params["a"] + context.params["b"]
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

    describe "#call" do
      let(:context) { double(Moleculer::Context, params: { "a" => 1, "b" => 2 }) }
      it "calls the action" do
        expect(subject.call("add", context)).to eq(3)
      end
    end
  end
end
