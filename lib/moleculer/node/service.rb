class Moleculer::Node::Service
  attr_reader :name, :settings, :metadata, :actions

  def self.info_from_class(klass)
    info = {
      name: klass.moleculer_service_name,
      settings: klass.moleculer_settings,
      metadata: klass.moleculer_metadata,
      actions: Hash[klass.moleculer_actions.keys.collect { |action|
        [ action,
          {
          name: "#{klass.moleculer_service_name}.#{action}",
          raw_name: action
        }]
      }]
    }
    info
  end

  def initialize(service)
    service = HashWithIndifferentAccess.new(service)
    @name = service[:name]
    @settings = service[:settings]
    @metadata = service[:metadata]
    @actions = parse_actions(service[:actions])
  end

  private

  def parse_actions(actions)
    actions.values.collect do |action|
      Action.new(action)
    end
  end
end

require_relative "./action"
