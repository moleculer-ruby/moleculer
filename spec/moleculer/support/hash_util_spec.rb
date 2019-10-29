# frozen_string_literal: true

RSpec.describe Moleculer::Support::HashUtil do
  subject { Moleculer::Support::HashUtil }

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

    describe "#merge" do
      it "returns a new hash that has been deep converted" do
        expect(subject.merge(
                 test_six: 6,
               ).to_camelized_hash).to include("testSix" => 6)
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
