RSpec.describe Moleculer::Packet do
  subject { Moleculer::Packet.new(foo: "bar") }

  it "merges in the base hash" do
    expect(subject[:foo]).to eq "bar"
  end

  it "sets ver" do
    expect(subject[:ver]).to eq "3"
  end

  it "sets sender" do
    expect(subject[:sender]).to eq Moleculer.node_id
  end
end
