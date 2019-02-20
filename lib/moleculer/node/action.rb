class Moleculer::Node::Service::Action
  attr_reader :name, :raw_name, :cache, :metrics

  def initialize(action)
    @name = action["name"]
    @raw_name = action["rawName"]
    @cache = action["cache"]
    @metrics = Metrics.new(action["metrics"])
  end
end


require_relative "./metrics"
