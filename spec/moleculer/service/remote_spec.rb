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

  describe "actions" do
    let(:instance) do
      Moleculer::Service.from_remote_info({
        name:    "test",
        actions: { test: { name: "test" } },
        events:  {},
      }, "node").new(broker)
    end

    before :each do
      allow(broker).to receive(:req)
    end

    it "returns #{Moleculer::Service::Action::REMOTE_IDENTIFIER} when a remote action is executed" do
      expect(instance.action_0(double(Moleculer::Context,
                                      id: "test", action: double(Moleculer::Service::Action, name: "test"),
                                      params: {},
                                      meta: {},
                                      timeout: 1,
                                      request_id: "test"))).to eq(Moleculer::Service::Action::REMOTE_IDENTIFIER)
    end
  end
end
