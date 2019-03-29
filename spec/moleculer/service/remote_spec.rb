RSpec.describe Moleculer::Service::Remote do
  describe "::from_remote_info" do
    let(:context) { {} }

    it "constructs a Remote service class from the provided service info" do
      service = subject.from_remote_info(
        name:    "test",
        actions: [
          { name: "action_one" },
        ],
      )

      expect(Moleculer.broker).to receive(:publish_req).with(context).and_return(success: true)

      expect(service.superclass).to eq Moleculer::Service::Remote
      expect(service.actions.length).to eq 1
      expect(service.actions["action_one"]).to be_a Moleculer::Service::Action
      expect(service.actions["action_one"].instance_variable_get(:@method)).to eq :action_0
      expect(service.actions["action_one"].execute(context))
    end
  end
end
