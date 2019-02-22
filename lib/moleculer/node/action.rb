class Moleculer::Node::Service::Action
  attr_reader :name, :raw_name, :cache, :metrics

  def initialize(action)
    action = HashWithIndifferentAccess.new(action)
    @name = action[:name]
    @raw_name = action[:rawName] || action[:raw_name]
    @cache = action[:cache]
    @metrics = Metrics.new(action[:metrics]) if action[:metrics]
  end
end


require_relative "./metrics"
