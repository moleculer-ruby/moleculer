# frozen_string_literal: true

RSpec.describe Moleculer::Broker::MessageProcessor do
  describe "#process_rpc_request" do
    let(:context) { { future: double("Future", fulfill: true) } }
    let(:data)    { {} }
    let(:packet)  { double(Moleculer::Packets::Res, data: data) }

    it "calls fulfill on the context future with the packet data" do
      subject.process_rpc_response(context, packet)
      expect(context[:future]).to have_received(:fulfill).with(packet.data)
    end
  end
end
