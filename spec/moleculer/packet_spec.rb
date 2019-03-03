RSpec.describe Moleculer::Packet do
  subject { Moleculer::Packet.new({foo: "bar"}, Moleculer::Packet::Types::INFO) }

  it "merges in the base hash" do
    expect(subject[:foo]).to eq "bar"
  end

  it "sets ver" do
    expect(subject[:ver]).to eq "3"
  end

  it "sets ver" do
    expect(subject[:type]).to eq Moleculer::Packet::Types::INFO
  end

  it "sets sender" do
    expect(subject[:sender]).to eq Moleculer.node_id
  end
end
