# frozen_string_literal: true

RSpec.describe Moleculer::Service::Base do
  subject do
    Class.new(Moleculer::Service::Base) do
      service_name "some-service"
      version "beta-0.0.1"
    end
  end

  let(:no_version) do
    Class.new(Moleculer::Service::Base) do
      service_name "other-service"
    end
  end

  let(:numeric_version) do
    Class.new(Moleculer::Service::Base) do
      service_name "different-service"
      version 2
    end
  end

  let(:broker) do
    Moleculer::Broker.new(Moleculer::Configuration.new(
                            service_prefix: "test",
                            services:       [subject, no_version, numeric_version],
                          ))
  end

  before :each do
    subject.broker         = broker
    no_version.broker      = broker
    numeric_version.broker = broker
  end

  describe "class methods" do
    describe "::service_prefix" do
      describe "local node" do
        it "should use the configured prefix for the broker" do
          expect(subject.service_name).to eq("test.some-service")
        end
      end
    end

    describe "::version" do
      describe "local node" do
        it "should use the configured string based version name" do
          expect(subject.version).to eq("beta-0.0.1")
        end

        it "should use the configured number based version name" do
          expect(numeric_version.version).to eq(2)
        end

        it "returns nil when version wasn't defined" do
          expect(no_version.version).to eq(nil)
        end
      end
    end

    describe "::full_name" do
      describe "local node" do
        it "should use the configured service prefix name and string version" do
          expect(subject.full_name).to eq("test.beta-0.0.1.some-service")
        end

        it "return the full name of the service with no version" do
          expect(no_version.full_name).to eq("test.other-service")
        end

        it "should use the configured service prefix name and number version" do
          expect(numeric_version.full_name).to eq("test.v2.different-service")
        end
      end
    end
  end
end
