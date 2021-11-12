# frozen_string_literal: true

require "spec_helper"

RSpec.describe Moleculer::Broker do
  let(:service) do
    Class.new(Moleculer::Service::Base) do
      name "math"

      action "sum", :sum

      def sum(ctx)
        ctx.params[:a] + ctx.params[:b]
      end
    end
  end

  subject { Moleculer::Broker.new(services: [service]) }
  describe "#initialize" do
    it "should create a broker with defaults" do
      expect(subject).to be_a(Moleculer::Broker)
      expect(subject.started).to be_falsey
      expect(subject.instance_id).to_not be_empty
    end
  end

  describe "#call" do
    it "should call a service" do
      expect(subject.call("math.sum", { a: 1, b: 2 })).to eq(3)
    end
  end
end
