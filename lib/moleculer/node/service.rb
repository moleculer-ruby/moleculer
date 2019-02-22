class Moleculer::Node::Service
  attr_reader :name, :settings, :metadata, :actions

  def self.from_class(klass)
    info = {
      name: klass.moleculer_service_name,
      settings: klass.moleculer_settings,
      metadata: klass.moleculer_metadata,
      actions: Hash[klass.moleculer_actions.keys.collect { |action|
        [ action,
          {
          name: "#{klass.moleculer_service_name}.#{action}",
          raw_name: action,
          params: {},
          metrics: {}
        }]
      }],
      events: []
    }
    info
  end

  def initialize(service)
    @data = HashWithIndifferentAccess.new(service)
    @name = @data[:name]
    @settings = @data[:settings]
    @metadata = @data[:metadata]
    @actions = parse_actions(@data[:actions])
  end

  def to_h
    @data
  end

  private

  def parse_actions(actions)
    actions.values.collect do |action|
      Action.new(action)
    end
  end
end

require_relative "./action"






