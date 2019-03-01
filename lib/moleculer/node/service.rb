class Moleculer::Node::Service
  attr_reader :name, :settings, :metadata, :actions, :events

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
      events: Hash[klass.moleculer_events.keys.collect { |event|
        [event,
          {
            name: event,
          }]
      }],
    }
    info
  end

  def initialize(service)
    @data = HashWithIndifferentAccess.new(service)
    @name = @data[:name]
    @settings = @data[:settings]
    @metadata = @data[:metadata]
    @actions = parse_actions(@data[:actions])
    @events = parse_events(@data[:events])
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

  def parse_events(events)
    events.values.collect do |event|
      Event.new(event)
    end
  end
end

require_relative "./action"
require_relative "./event"





