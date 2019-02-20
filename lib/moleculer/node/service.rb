class Moleculer::Node::Service
  attr_reader :name, :settings, :metadata, :actions

  def initialize(service)
    @name = service["name"]
    @settings = service["settings"]
    @metadata = service["metadata"]
    @actions = parse_actions(service["actions"])
  end

  private

  def parse_actions(actions)
    actions.values.collect do |action|
      Action.new(action)
    end
  end

end

require_relative "./action"
