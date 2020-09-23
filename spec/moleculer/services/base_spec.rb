# frozen_string_literal: true

RSpec.describe Moleculer::Service::Base do
  subject do
    Class.new(Moleculer::Service::Base) do
      service_name "test"

      action :test_action
      event  :test_event

      settings(
        '$secure_settings': [:secure_setting, "deep.secure.setting"],
        other_setting:      :other,
        secure_setting:     :secure,
        deep:               {
          secure: {
            setting:  true,
            insecure: false,
          },
        },
      )

      metadata(
        meta: :data,
      )

      def test_action(_ctx); end
    end.new(double("broker"))
  end

  describe "::metadata" do
    context "getter" do
      subject do
        Class.new(Moleculer::Service::Base) do
          service_name "test"

          metadata(
            setting_1: true,
          )
        end
      end

      it "returns the metadata" do
        expect(subject.metadata).to eq({
          setting_1: true,
        })
      end

      context "with parent" do
        let(:parent) do
          Class.new(Moleculer::Service::Base) do
            service_name "test"

            metadata(
              setting_1: true,
              setting_3: "setting_three",
            )
          end
        end

        let(:subject) do
          Class.new(parent) do
            metadata({
              setting_2: "child_setting",
              setting_3: :setting_3,
            })
          end
        end

        it "merges the parent setting with the child setting" do
          expect(subject.metadata).to eq({
            setting_1: true,
            setting_2: "child_setting",
            setting_3: :setting_3,
          })
        end
      end
    end
  end

  describe "::settings" do
    context "getter" do
      subject do
        Class.new(Moleculer::Service::Base) do
          service_name "test"

          settings(
            setting_1: true,
          )
        end
      end

      it "returns the settings" do
        expect(subject.settings).to eq({
          setting_1: true,
        })
      end

      context "with parent" do
        let(:parent) do
          Class.new(Moleculer::Service::Base) do
            service_name "test"

            settings(
              setting_1: true,
              setting_3: "setting_three",
            )
          end
        end

        let(:subject) do
          Class.new(parent) do
            settings({
              setting_2: "child_setting",
              setting_3: :setting_3,
            })
          end
        end

        it "merges the parent setting with the child setting" do
          expect(subject.settings).to eq({
            setting_1: true,
            setting_2: "child_setting",
            setting_3: :setting_3,
          })
        end
      end
    end
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
        settings:  {
          other_setting: :other,
          deep:          {
            secure: {
              insecure: false,
            },
          },
        },
        metadata:  {
          meta: :data,
        },
      })
    end
  end
end
