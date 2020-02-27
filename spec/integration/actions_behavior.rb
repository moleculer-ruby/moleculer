# frozen_string_literal: true

require_relative "integration_spec_helper"

RSpec.shared_examples "moleculer actions" do |transporter, serializer|
  before :context do
    @broker = create_broker("local", transporter, serializer, LocalService)
    @remote = create_broker("remote", transporter, serializer, RemoteService)
    @broker.start
    @remote.start
    @broker.wait_for_services("local", "remote")
  end

  after :each do
    @broker.stop
    @remote.stop
  end

  context "#{transporter} transporter" do
    context "#{serializer} serializer" do
      describe "remote actions" do
        it "returns a result from remote actions" do
          expect(@broker.call("remote.test", {})).to eq(result: "remote action result")
        end

        it "correctly passes meta data" do
          expect(@broker.call("remote.test_with_meta", {}, meta: { foo: "bar" })).to eq(result: { foo: "bar" })
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
