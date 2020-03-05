# frozen_string_literal: true

require_relative "integration_spec_helper"

RSpec.shared_examples "moleculer actions" do |transporter, serializer|
  before :all do
    @broker = create_broker("local", transporter, serializer, LocalService)
    @remote = create_broker("remote", transporter, serializer, RemoteService)
    @broker.start
    @remote.start
    @broker.wait_for_services("local", "remote")
  end

  after :all do
    @broker.stop
    @remote.stop
  end

  context "#{transporter} transporter" do
    context "#{serializer} serializer" do
      describe "remote actions" do
        context "normal call" do
          it "returns a result from remote actions" do
            expect(@broker.call("remote.test", {})).to eq(result: "remote action result")
          end
        end

        context "with metadata" do
          it "correctly passes meta data" do
            expect(@broker.call("remote.test_with_meta", {}, meta: { foo: "bar" })).to eq(result: { foo: "bar" })
          end
        end

        context "with timeout" do
          it "raises a timeout error" do
            expect { @broker.call("remote.test_with_timeout", nil, timeout: 0.1, retries: 0) }
              .to raise_exception(Moleculer::Errors::RequestTimeoutError)
          end
        end

        context "With retries" do
          it "retries the provided number of times" do
            expect(@broker.call("remote.test_with_retries", nil, retries: 5))
              .to eq(retries: 5)
          end
        end
      end

      describe "local actions" do
        it "returns a result from local actions" do
          expect(@broker.call("local.test", {})).to eq(result: "local action result")
        end

        it "correctly passes meta data" do
          expect(@broker.call("local.test_with_meta", {}, meta: { foo: "bar" })).to eq(result: { foo: "bar" })
        end
      end
    end
  end
end
