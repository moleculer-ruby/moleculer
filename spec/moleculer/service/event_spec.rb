RSpec.describe Moleculer::Service::Event do
  let(:config) { Moleculer::Configuration.new }
  let(:broker) { instance_double(Moleculer::Broker, config: config, rescue_event: nil) }

  subject do
    Moleculer::Service::Event.new(
      "event.name",
      service,
      :some_method,
      some: "options",
      rescue_event: nil
    )
  end

  describe "#execute" do
    subject { Moleculer::Service::Event.new("test", service, :test_event) }

    describe "an exception is raised when no rescue_event handler is configured" do
      let(:service) do
        Class.new(Moleculer::Service::Base) do
          def test_event(_)
            raise StandardError, "test error"
          end
        end
      end

      it "raises an exception if a hash is not returned" do
        expect { subject.execute({}, broker) }.to raise_error(StandardError)
      end
    end

    describe "rescue_event is configured" do
      let(:errors) { [] }
      let(:service) do
        Class.new(Moleculer::Service::Base) do
          def test_event(_)
            raise StandardError, "test error"
          end
        end
      end

      before :each do
        allow(broker).to receive(:rescue_event).and_return(-> (e) { errors << e })
      end

      it "handles the error using the rescue_event proc" do
        subject.execute({}, broker)
        expect(errors.last).to be_instance_of(StandardError)
      end
    end
  end
end
