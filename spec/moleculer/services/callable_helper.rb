# frozen_string_literal: true

RSpec.shared_examples Moleculer::Service::Callable do
  let(:service) { double(Moleculer::Service::Base, name: "service") }

  let(:default_params) do
    {
      name: "test",
      method: nil
    }
  end

  context "with method" do
    subject do
      callable_class.new(
        service,
        **default_params.merge(params).merge(method: :test)
      )
    end

    describe "#call" do
      it "calls the defined method from the service" do
        expect(service).to receive(:test).with("foo", "bar", foo: :bar)

        subject.call("foo", "bar", foo: :bar)
      end
    end
  end

  context "with block" do
    let(:callback) { double("callback", call: true) }
    subject do
      callable_class.new(
        service,
        **default_params.merge(params)
      ) { |*args, **kwargs| callback.call(*args, **kwargs) }
    end

    describe "#call" do
      it "calls the block" do
        expect(callback).to receive(:call).with("foo", "bar", foo: :bar)

        subject.call("foo", "bar", foo: :bar)
      end
    end
  end

  describe "#schema" do
    subject do
      callable_class.new(
        service,
        **default_params.merge(params).merge(method: :test)
      )
    end

    it "returns the correct schema" do
      expect(subject.schema).to eq({
        name: "test"
      }.merge(expected_schema))
    end
  end
end
