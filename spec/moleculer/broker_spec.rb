# frozen_string_literal: true

require "spec_helper"

RSpec.describe Moleculer::Broker do
  describe "#initialize" do
    it "should create a broker with defaults" do
      broker = Moleculer::Broker.new
      expect(broker).to be_a(Moleculer::Broker)
      expect(broker.started).to be_falsey
      expect(broker.instance_id).to_not be_empty
    end
  end
end
