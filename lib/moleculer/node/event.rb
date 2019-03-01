class Moleculer::Node::Service::Event
  attr_reader :pattern, :metrics

  def initialize(event)
    @pattern = event["name"]
  end
end


require_relative "./metrics"
