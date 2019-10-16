# frozen_string_literal: true

require_relative "../../../lib/moleculer/serializers/msg_pack"
require_relative "serializer_behavior"

RSpec.describe Moleculer::Serializers::MsgPack do
  let(:config) { Moleculer::Configuration.new }
  subject { described_class.new(config) }

  include_examples "serializer"
end
