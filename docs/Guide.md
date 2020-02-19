
## Getting Started
### Install the Gem

```ruby
gem install "moleculer-ruby"
```

or add to your Gemfile:

```ruby
gem "moleculer-ruby", "~>0.3"
```

## The Service Broker
{include:Moleculer::Broker}

## Actions

![Actions Diagram](images/action-balancing.gif)

{include:Moleculer::Broker::Actions}
### Call Services
{render_method:Moleculer::Broker::Actions#call}
