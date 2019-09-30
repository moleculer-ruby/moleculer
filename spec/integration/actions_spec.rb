require_relative "integration_spec_helper"

RSpec.describe "moleculer actions" do
  it "Should" do
    expect(broker.call("local.test", {})).to eq("test")
  end
end