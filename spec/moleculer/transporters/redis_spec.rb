require "moleculer/transporters/redis"
RSpec.describe Moleculer::Transporters::Redis do
  before :each do
    allow(::Redis).to receive(:new).and_return(instance_double(::Redis::Client))
  end


  # Most of the testing here takes place in the integration test, this simply tests that redis complies with the
  # expected interface
  it "responds to #publish" do
    expect(subject).to respond_to(:publish)
  end

  it "responds to subscribe" do
    expect(subject).to respond_to(:subscribe)
  end

  it "responds to #connect" do
    expect(subject).to respond_to(:connect)
  end

  it "responds to #disconnect" do
    expect(subject).to respond_to(:disconnect)
  end
end
