require "spec_helper"

RSpec.describe Moleculer::Context do
  let(:broker) { double(Moleculer::Broker) }
  subject { Moleculer::Context.new(broker) }

  describe "#broker" do
    it "should be the broker" do
      expect(subject.broker).to eq(broker)
    end
  end
end