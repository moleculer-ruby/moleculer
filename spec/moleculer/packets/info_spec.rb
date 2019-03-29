RSpec.describe Moleculer::Packets::Info do
  subject { Moleculer::Packets::Info }

  let(:info) do
    {
      config:   {},
      ip_list:  ["127.0.0.1"],
      hostname: "some-host",
      client:   {
        type:         "ruby",
        version:      "0.1.0",
        lang_version: "2.0",
      },
      services: services,
    }
  end

  let(:services) do
    [
      {
        name:    "test",
        actions: {
          "some-action": {
            name: "some-action"
          }
        },
      },
    ]
  end

  it "parses the service info into an Info class instance" do
    packet = subject.new(info)

    expect(packet.services.first.superclass).to eq Moleculer::Service::Remote
    expect(packet.services.first.actions["some-action"]).to be_a Moleculer::Service::Action
    expect(packet.services.first.actions["some-action"].instance_variable_get(:@name)).to eq "some-action"
  end
end
