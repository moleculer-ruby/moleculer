# frozen_string_literal: true

require_relative "integration_spec_helper"

RSpec.shared_examples "moleculer events" do |transporter, serializer|
  before :context do
    @broker = create_broker("local", transporter, serializer, LocalService)
    @remote = create_broker("remote", transporter, serializer, RemoteService)
    @broker.start
    @remote.start
    @remote.wait_for_services("local")
    @broker.wait_for_services("local", "remote")
  end

  before :each do
    CallTracker.reset
  end

  context "#{transporter} transporter" do
    context "#{serializer} serializer" do
      describe "remote events" do
        it "returns a result from remote events" do
          @broker.emit("test-remote-event", {})
          sleep 0.1
          expect(CallTracker.events_called["test-remote-event"]).to eq(1)
        end
      end

      describe "local events" do
        it "returns a result from local events" do
          @broker.emit("test-local-event", {})
          sleep 1
          expect(CallTracker.events_called["test-local-event"]).to eq(1)
        end
      end
    end
  end
end

