RSpec.describe(Moleculer::Service::Base) do
  subject {
    Class.new(Moleculer::Service::Base) do
      self.service_prefix = "service"

      action "test", :test_action, cache: false, params: {
        string: String,
        number: Integer
      }

      event "test.event", :test_event


      def test_action(ctx)
      end

      def test_event(payload, sender, event_name)
      end
    end
  }

  describe "::service_prefix" do
    it "sets the service prefix instance variable" do
      expect(subject.service_prefix).to eq "service"
    end

    it "allows child classes to inherit the service prefix" do
      child = Class.new(subject)
      expect(child.service_prefix).to eq "service"
    end

    it "allows child classes to set their own service prefix" do
      child = Class.new(subject) do
        self.service_prefix = "child-service"
      end

      expect(child.service_prefix).to eq "child-service"
    end
  end

  describe "::service_name" do
    it "sets the prefixed service_name" do
      child = Class.new(subject) do
        service_name "child"
      end

      expect(child.service_name).to eq "service.child"
    end

    it "does not set the prefix for a non prefixed child" do
      parent = Class.new(Moleculer::Service::Base)
      child = Class.new(parent) do
        service_name "child"
      end

      expect(child.service_name).to eq "child"
    end
  end

  describe "::action" do
    it "creates an action object with the given object and parameters" do
      expect(subject.actions.keys.length).to eq 1
      expect(subject.actions[:test]).to be_an_instance_of Moleculer::Service::Action::Local
    end
  end

  describe "::event" do
    it "creates an action object with the given object and parameters" do
      expect(subject.events.keys.length).to eq 1
      expect(subject.events["test.event"]).to be_an_instance_of Moleculer::Service::Event::Local
    end
  end
end
