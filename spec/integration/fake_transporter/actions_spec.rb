# frozen_string_literal: true

require_relative "../../egration_spec_helper"
require_relative "../../../integration/actions_behavior"

RSpec.describe "actions" do
  it_behaves_like "moleculer actions", "fake", :json
end
