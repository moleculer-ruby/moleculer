# frozen_string_literal: true

RSpec.describe Moleculer::Service::Base do
  subject do
    Class.new(Moleculer::Service::Remote) do
      service_name "some-service"
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
      describe "remote service " do
        it "should not use the configured prefix for the broker" do
          expect(subject.service_name).to eq("some-service")
        end
      end
    end
  end
end
