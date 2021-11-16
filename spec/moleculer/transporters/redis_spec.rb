# frozen_string_literal: true

require_relative "../../spec_helper"

require "moleculer/transporters/redis"
require "concurrent/atomic/event"

RSpec.describe Moleculer::Transporters::Redis do
  subject { described_class.new({url: "redis://localhost:6379"}, serializer: nil).connect }

  let(:test) { double("test", message: true) }

  let(:publisher) { subject.instance_variable_get(:@publisher) }
  let(:subscriber) { subject.instance_variable_get(:@subscriber) }

  describe "#publish and #subscribe" do
    it "should publish and subscribe" do
      event = Concurrent::Event.new

      subject.subscribe("MOL-INFO") do |message|
        test.message(message)
        event.set
      end

      publisher.publish("MOL-INFO", "message")

      event.wait

      expect(test).to have_received(:message).with("message")
    end
  end
end
