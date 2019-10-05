# frozen_string_literal: true

require_relative "integration_spec_helper"

RSpec.describe "moleculer actions" do
  describe "remote actions" do
    it "returns a result from remote actions" do
      expect(broker.call("remote.test", {})).to eq(result: "remote action result")
    end
  end

  describe "local actions" do
    it "returns a result from local actions" do
      expect(broker.call("local.test", {})).to eq(result: "local action result")
    end
  end
end
