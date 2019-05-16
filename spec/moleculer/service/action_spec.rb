RSpec.describe Moleculer::Service::Action do
  let(:config) { Moleculer::Configuration.new }
  let(:broker) { instance_double(Moleculer::Broker, config: config) }

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
        expect { subject.execute(context, broker) }.to raise_error(Moleculer::Errors::InvalidActionResponse)
      end
    end

    describe "handles exceptions used the configured rescue_action config" do
      let(:errors) { [] }
      let(:service) do
        Class.new(Moleculer::Service::Base) do
          def test_action(_)
            raise StandardError, "an error occurred"
          end
        end
      end

      before :each do
        config.rescue_action = -> (e) { errors << e }
      end

      it "handles the raised exception using the configured rescue_action" do
        expect { subject.execute(context, broker) }.to_not raise_error
        expect(errors.last).to be_instance_of(StandardError)
      end
    end
  end
end
