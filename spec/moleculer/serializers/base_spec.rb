# frozen_string_literal: true

require "spec_helper"

RSpec.describe Moleculer::Serializers::Base do
  let(:broker) { Moleculer::Broker.new(logger: Console::Logger.new(Console::Output::Null.new)) }

  subject { described_class.new(broker:) }

  describe "#initialize" do
    it "initializes with a broker" do
      expect(subject.broker).to eq(broker)
    end
  end

  describe "#serialize" do
    it "raises NotImplementedError" do
      expect { subject.serialize(object: {}, type: :any) }.to raise_error(NotImplementedError)
    end
  end

  describe "#deserialize" do
    it "raises NotImplementedError" do
      expect { subject.deserialize(data: "", type: :any) }.to raise_error(NotImplementedError)
    end
  end
end
