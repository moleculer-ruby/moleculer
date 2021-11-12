# frozen_string_literal: true

require "spec_helper"

RSpec.describe Moleculer::Broker do
  let(:registry) { double(Moleculer::Registry) }
  let(:context) { double(Moleculer::Context) }

  before :each do
    allow(Moleculer::Registry).to receive(:new).and_return(registry)
    allow(Moleculer::Context).to receive(:new).and_return(context)
  end

  describe "#initialize" do
    it "should create a broker with defaults" do
      expect(subject).to be_a(Moleculer::Broker)
      expect(subject.started).to be_falsey
      expect(subject.instance_id).to_not be_empty
    end
  end

  describe "#call" do
    it "should call a service" do
      expect(registry).to receive(:call).with("test", context)
      expect(Moleculer::Context).to receive(:new).with(subject, { a: 1, b: 2 }).and_return(context)

      subject.call("test", { a: 1, b: 2 })
    end
  end
end
