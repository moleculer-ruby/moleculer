# frozen_string_literal: true

RSpec.describe Moleculer::Service::Action do
  let(:config) { Moleculer::Configuration.new }
  let(:broker) do
    instance_double(Moleculer::Broker, config: config)
  end

  let(:context) { instance_double(Moleculer::Context) }

  describe "#execute" do
    subject { Moleculer::Service::Action.new("test", service, :test_action) }

    describe "correctly defined method" do
      let(:service) do
        Class.new(Moleculer::Service::Base) do
          def test_action(_)
            {}
          end
        end
      end

      it "returns a valid response" do
        expect(subject.execute(context, broker)).to eq({})
      end
    end

    describe "returning an invalid response" do
      let(:service) do
        Class.new(Moleculer::Service::Base) do
          def test_action(_)
            "not a hash"
          end
        end
      end

      it "raises an exception if a hash is not returned" do
        allow(broker.config.logger).to receive(:error)
        subject.execute(context, broker)
        expect(broker.config.logger).to have_received(:error).with(instance_of(Moleculer::Errors::InvalidActionResponse))
      end
    end

    describe "handles exceptions used the configured rescue_from config" do
      let(:error) { StandardError.new("an error occurred") }
      let(:service) do
        Class.new(Moleculer::Service::Base) do
          def test_action(_)
            raise StandardError, "test"
          end
        end
      end

      before :each do
        allow(broker.config.logger).to receive(:error).and_return(nil)
      end

      it "handles the raised exception using the configured rescue_action" do
        expect { subject.execute(context, broker) }.to_not raise_error
        expect(broker.config.logger).to have_received(:error).with(instance_of(StandardError))
      end
    end
  end
end
