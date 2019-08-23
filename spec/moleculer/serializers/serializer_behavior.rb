# frozen_string_literal: true

##
# @private

RSpec.shared_examples "serialize packet" do |data, packet|
  it "should serialize the #{packet.name} class" do
    expect { subject.serialize(packet.new(config, data)) }.to_not raise_error
    expect(subject.serialize(packet.new(config, data))).to be_a String
  end
end

RSpec.shared_examples "serializer" do
  describe "#serialize" do
    include_examples "serialize packet", {}, Moleculer::Packets::Discover
    include_examples "serialize packet", {}, Moleculer::Packets::Disconnect
    include_examples "serialize packet", {
      event:     "test",
      data:      {},
      broadcast: false,
    }, Moleculer::Packets::Event
    include_examples "serialize packet", {}, Moleculer::Packets::Heartbeat
    include_examples "serialize packet", {
      services: {},
      ip_list:  [],
      hostname: "",
    }, Moleculer::Packets::Info
    include_examples "serialize packet", {
      id:     "",
      action: "",
      params: {},
      meta:   {},
    },
                     Moleculer::Packets::Req
    include_examples "serialize packet", {
      id:      "",
      success: true,
      data:    {},
      meta:    {},
    }, Moleculer::Packets::Res
  end
end
