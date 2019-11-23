# frozen_string_literal: true

require_relative "../../integration_spec_helper"
require_relative "../../../integration/events_behavior"

RSpec.describe "events" do
  it_behaves_like "moleculer events", "redis", :json
end
