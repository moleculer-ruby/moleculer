# frozen_string_literal: true

RSpec.shared_examples "targeted packet" do
  it "returns the correct topic" do
    expect(subject.topic).to eq("MOL.#{subject.class.packet_name}.#{subject.sender}")
  end
end
