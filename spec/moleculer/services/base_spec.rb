# frozen_string_literal: true

RSpec.describe Moleculer::Service::Base do
  subject do
    Class.new(Moleculer::Service::Base) do
      service_name "test"

      action :test_action
      event  :test_event

      def test_action(_ctx); end
    end.new(double("broker"))
  end

  describe "::full_name" do
    context "no_version_prefix is true (default)" do
      subject do
        Class.new(Moleculer::Service::Base) do
          service_name "test"
        end
      end

      it "should simply return the name" do
        expect(subject.full_name).to eq("test")
      end
    end

    context "no_version_prefix is false" do
      context "with Integer version" do
        subject do
          Class.new(Moleculer::Service::Base) do
            service_name "test"
            no_version_prefix false
            version 1
          end
        end
        it "should prefix the version with v(version) to the name" do
          expect(subject.full_name).to eq("v1.test")
        end
      end

      context "with string version" do
        subject do
          Class.new(Moleculer::Service::Base) do
            service_name "test"
            no_version_prefix false
            version "1"
          end
        end

        it "should prefix the string version to the name" do
          expect(subject.full_name).to eq("1.test")
        end
      end
    end
  end

  describe "#schema" do
    it "returns a valid service schema" do
      expect(subject.schema).to eq({
        name:      "test",
        full_name: "test",
        version:   "0",
        actions:   {
          test_action: {
            cache:    false,
            metrics:  {
              meta:   false,
              params: false,
            },
            name:     "test.test_action",
            params:   {},
            raw_name: :test_action,
          },

        },
        events:    {
          test_event: {
            name: :test_event,
          },
        },
      })
    end
  end
end
