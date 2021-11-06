# frozen_string_literal: true

require "spec_helper"

RSpec.describe Moleculer::Serializers::JSON do
  subject { described_class.new }

  it "should serialize" do
    expect(subject.serialize({ "a" => 1 })).to eq('{"a":1}')
  end

  it "should deserialize" do
    expect(subject.deserialize('{"a":1}')).to eq({ "a" => 1 })
  end
end
