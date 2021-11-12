# frozen_string_literal: true

require "spec_helper"

RSpec.describe Moleculer::Registry do
  let(:broker) { double(Moleculer::Broker) }
  let(:local_node) { double(Moleculer::Node) }
  let(:context) { double(Moleculer::Context) }

  subject do
    described_class.new(broker, local_node)
  end

  describe "#call" do
    it "should call the local node" do
      expect(local_node).to receive(:call).with("math.add", context)

      # noinspection RubyMismatchedArgumentType
      subject.call("math.add", context)
    end
  end
end
