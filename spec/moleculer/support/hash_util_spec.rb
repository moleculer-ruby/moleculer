# frozen_string_literal: true

RSpec.describe Moleculer::Support::HashUtil do
  subject { Moleculer::Support::HashUtil }

  describe "::fetch" do
    let!(:obj) do
      double
    end

    let(:hash) do
      {
        "test_one" => 1,
        "testTwo" => 2,
        testThree: 3,
        test_four: 4,
        obj => 5,
      }
    end

    it "fetches correctly" do
      expect(subject.fetch(hash, :testOne)).to eq 1
      expect(subject.fetch(hash, :test_two)).to eq 2
      expect(subject.fetch(hash, "test_three")).to eq 3
      expect(subject.fetch(hash, "testFour")).to eq 4
      expect(subject.fetch(hash, obj)).to eq 5
      expect(subject.fetch(hash, :not_there, "foo")).to eq "foo"
    end
  end

  describe "::stringify_keys" do
    it "recursively stringifies keys" do
      expect(subject.stringify_keys(foo: { bar: "baz" })).to eq("foo" => { "bar" => "baz" })
    end
  end

  describe "::symbolize_keys" do
    it "recursively symbolizes keys" do
      expect(subject.symbolize_keys("foo" => { "bar" => "baz" })).to eq(foo: { bar: "baz" })
    end
  end

  describe Moleculer::Support::HashUtil::HashWithIndifferentAccess do
    let!(:obj) do
      double
    end

    subject do
      Moleculer::Support::HashUtil::HashWithIndifferentAccess.from_hash(
        "test_one" => 1,
        "testTwo" => 2,
        testThree: 3,
        test_four: 4,
        test_five: {
          subTest: 1,
        },
        obj => 5,
      )
    end

    it "should normalize all of the keys" do
      expect(subject.to_h).to include(
        test_one: 1,
        test_two: 2,
        test_three: 3,
        test_four: 4,
        test_five: {
          sub_test: 1,
        },
        obj => 5,
      )
    end

    describe "#stringify_keys" do
      it "it stringifies the keys" do
        expect(subject.stringify_keys.to_h).to include(
          "test_one"   => 1,
          "test_two"   => 2,
          "test_three" => 3,
          "test_four"  => 4,
          "test_five"  => {
            "sub_test" => 1,
          },
          obj          => 5,
        )
      end
    end

    describe "#to_camelized_hash" do
      it "returns a hash with camelized values" do
        expect(subject.to_camelized_hash).to include(
          "testOne"   => 1,
          "testTwo"   => 2,
          "testThree" => 3,
          "testFour"  => 4,
          "testFive"  => {
            "subTest" => 1,
          },
          obj         => 5,
        )
      end
    end

    describe "#to_json" do
      it "returns json that can be used for moleculer messages" do
        expect(subject.to_json).to eq({
          "testOne"   => 1,
          "testTwo"   => 2,
          "testThree" => 3,
          "testFour"  => 4,
          "testFive"  => {
            "subTest" => 1,
          },
        }.to_json)
      end
    end
  end
end
