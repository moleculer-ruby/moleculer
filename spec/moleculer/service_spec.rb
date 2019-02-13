RSpec.describe Moleculer::Service do
  service = nil
  before :each do
    service = Class.new do
      include Moleculer::Service

      self.moleculer_service_name = "test.service"

      moleculer_action :some_action, :some_action

      def some_action; end
    end
  end

  describe "name" do
    it "allows the name to be set" do
      expect(service.moleculer_service_name).to eq "test.service"
    end
  end

  describe "actions" do
    it "allows actions to be added" do
      expect(service.moleculer_actions[:some_action]).to eq(:some_action)
    end
  end
end
