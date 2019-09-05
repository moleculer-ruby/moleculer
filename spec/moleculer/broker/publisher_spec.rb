# frozen_string_literal: true

require_relative "../../../lib/moleculer/transporters/base"

RSpec.describe Moleculer::Broker::Publisher do
  let(:transporter) { double(Moleculer::Transporters::Base, publish: true) }
  let(:broker) do
    double(Moleculer::Broker,
           config:      Moleculer::Configuration.new,
           transporter: transporter)
  end

  subject { Moleculer::Broker::Publisher.new(broker) }

  describe "#publish_event" do
    let(:event) { { event: "test.event", data: {}, broadcast: false} }

    it "publishes an event packet to the transporter" do
      subject.publish_event(event)
      expect(transporter).to have_received(:publish)
        .with(instance_of(Moleculer::Packets::Event))
    end
  end
end
