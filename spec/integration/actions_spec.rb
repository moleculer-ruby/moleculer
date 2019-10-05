# frozen_string_literal: true

require_relative "integration_spec_helper"

RSpec.describe "moleculer actions" do
  describe "remote actions" do
    it "returns a result from remote actions" do
      expect(broker.call("remote.test", {})).to eq(result: "remote action result")
    end
  end
end
