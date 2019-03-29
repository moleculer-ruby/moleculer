RSpec.describe Moleculer::Transporters::Redis do
  subject {Moleculer::Transporters::Redis}

  it "sets ::NAME" do
    expect(subject::NAME).to eq "Redis"
  end
end