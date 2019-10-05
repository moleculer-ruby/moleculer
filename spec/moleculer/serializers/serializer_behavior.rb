# frozen_string_literal: true

RSpec.shared_examples "serialize packet" do |data, packet|
  it "should serialize the #{packet.name} class" do
    expect { subject.serialize(packet.new(config, data)) }.to_not raise_error
    expect(subject.serialize(packet.new(config, data))).to be_a String
  end
end

RSpec.shared_examples "deserialize packet" do |data, packet|
  it "should deserialize the #{packet.name} class" do
    serialized_packet = subject.serialize(packet.new(config, data))
    expect { subject.deserialize(packet.name.split("::").last.downcase.to_sym, serialized_packet) }.to_not raise_error
    expect(subject.deserialize(packet.name.split("::").last.downcase.to_sym, serialized_packet)).to be_a packet
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
      ip_list:  ["127.0.0.1"],
      hostname: "test",
    }, Moleculer::Packets::Info
    include_examples "serialize packet", {
      id:     "test",
      action: "test",
      params: {},
      meta:   {},
    },
                     Moleculer::Packets::Req
    include_examples "serialize packet", {
      id:      "test",
      success: true,
      data:    {},
      meta:    {},
    }, Moleculer::Packets::Res
  end

  describe "#deserialize" do
    include_examples "deserialize packet", {}, Moleculer::Packets::Discover
    include_examples "deserialize packet", {}, Moleculer::Packets::Disconnect
    include_examples "deserialize packet", {
      event:     "test",
      data:      {},
      broadcast: false,
    }, Moleculer::Packets::Event
    include_examples "deserialize packet", {}, Moleculer::Packets::Heartbeat
    include_examples "deserialize packet", {
      services: {},
      ip_list:  ["127.0.0.1"],
      hostname: "test",
    }, Moleculer::Packets::Info
    include_examples "deserialize packet", {
      id:     "test",
      action: "test",
      params: {},
      meta:   {},
    },
                     Moleculer::Packets::Req
    include_examples "deserialize packet", {
      id:      "test",
      success: true,
      data:    {},
      meta:    {},
    }, Moleculer::Packets::Res
  end
end
