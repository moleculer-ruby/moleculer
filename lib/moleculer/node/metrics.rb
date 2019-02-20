class Moleculer::Node::Service::Action::Metrics
  attr_reader :params, :meta

  def initialize(metrics)
    @params = metrics["params"]
    @meta = metrics["meta"]
  end
end
