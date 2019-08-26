require_relative "../../../lib/moleculer/serializers/json"
require_relative "serializer_behavior"

RSpec.describe Moleculer::Serializers::Json do
  let(:config) { Moleculer::Configuration.new }
  subject { Moleculer::Serializers::Json.new(config) }

  include_examples "serializer"
end
