# frozen_string_literal: true

require_relative "integration_spec_helper"

RSpec.shared_examples "moleculer actions" do |transporter, serializer|
  before :context do
    @broker = create_broker("local", transporter, serializer, LocalService)
    @remote = create_broker("remote", transporter, serializer, RemoteService)
    @broker.start
    @remote.start
    @remote.wait_for_services("local")
    @broker.wait_for_services("local", "remote")
  end

  context "#{transporter} transporter" do
    context "#{serializer} serializer" do
      describe "remote actions" do
        it "returns a result from remote actions" do
          expect(@broker.call("remote.test", {})).to eq(result: "remote action result")
        end
      end

      describe "local actions" do
        it "returns a result from local actions" do
          expect(@broker.call("local.test", {})).to eq(result: "local action result")
        end
      end
    end
  end
end

