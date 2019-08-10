# frozen_string_literal: true

RSpec.describe Moleculer::Service::Base do
  subject do
    Class.new(Moleculer::Service::Base) do
      service_name "some-service"
      version "beta-0.0.1"
    end
  end

  let!(:broker) do
    Moleculer::Broker.new(Moleculer::Configuration.new(
                            service_prefix: "test",
                            services:       [subject],
                          ))
  end

  before :each do
    subject.broker = broker
  end

  describe "class methods" do
    describe "::service_prefix" do
      describe "local node" do
        it "should use the configured prefix for the broker" do
          expect(subject.service_name).to eq("test.some-service")
          expect(subject.version).to eq("beta-0.0.1")
          expect(subject.full_name).to eq("test.beta-0.0.1.some-service")
        end
      end
    end
  end
end
