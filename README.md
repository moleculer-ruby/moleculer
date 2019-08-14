# Moleculer
![Moleculer logo](https://github.com/moleculerjs/moleculer/raw/master/docs/assets/logo.png)

[![Build Status](https://travis-ci.org/moleculer-ruby/moleculer.svg?branch=develop)](https://travis-ci.org/moleculer-ruby/moleculer)
[![Maintainability](https://api.codeclimate.com/v1/badges/d4211bbefca62cb4c10e/maintainability)](https://codeclimate.com/github/moleculer-ruby/moleculer/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/d4211bbefca62cb4c10e/test_coverage)](https://codeclimate.com/github/moleculer-ruby/moleculer/test_coverage)

Moleculer is a fast, modern and powerful microservices framework for originally written for [Node.js](). It helps you to 
build efficient, reliable & scalable services. Moleculer provides many features for building and managing your 
microservices.


## Getting Started
### Install the Gem

```ruby
gem install "moleculer-ruby"
```

or add to your Gemfile:

```ruby
gem "moleculer-ruby", "~>0.2"
```

### Create a  Simple Service

```ruby
class SimpleService < Moleculer::Service::Base
  action :get_user, :get_user
  
  
  def get_user
    # .. usery getting stuff
  end
end


Moleculer.config do |c|
  c.services << SimpleService
end

Moleculer.start

```


## Configuration

Moleculer is configured through the Moleculer::config method. Example:

```ruby
Moleculer.configure do |c|
  c.log_level = :debug
end
```

Some Moleculer configuration values can also be set through environment variables.

### Configuration Options

#### log_file (default: STDOUT)
Sets teh moleculer log_file. This value can also be set by setting the `MOLECULER_LOG_FILE` environment variable.

#### logger
Sets the moleculer logger. The logger must be an instance of `Moleculer::Support::LogProxy`. The log proxy supports any
ruby logger that supports the ruby `Logger` interface.

Example: 
```
c.logger = Moleculer::Support::Logger.new(Rails.logger)
```

In the case that the logger is set to something other than the default, the log level set for moleculer is ignored, and the
level of the passed logger is used.

#### log_level (default: debug)
Sets the log level of the node. defaults to `:debug`. Can be one of `:trace`, `:debug`, `:info`, `:warn`, `:error`, 
`:fatal`. This value can also be set by setting the `MOLECULER_LOG_LEVEL` environment variable.

#### heartbeat_interval (default: 5)
The interval in which to send heartbeats. This value can also be set by setting the `MOLECULER_HEARTBEAT` environment variable.

#### node_id (default: \<hostname\>-\<pid\>)
The node id. Node IDs are required to be unique. In Moleculer-ruby all node ids are suffixed with the PID of the 
running process, allowing multiple copies of the same node to be run on the same machine. When using a containerized
environment (i.e. Docker), it is suggested that the node_id also include a random set of characters as there is a chance
that does running in separate containers can have the same PID.

#### serializer (default: :json)
Which serializer to use. For more information serializers see [Serialization](https://moleculer.services/docs/0.13/networking.html#Serialization)

#### service_prefix (default: nil)
The service prefix. This will be prefixed to all services. For example if `service_prefix` were to be `foo` then a
service whose `service_name` is set to `users` would get the full `service_name` of `foo.users`.

#### timeout (default: 5)
The Moleculer system timeout. This is used to determine how long a moleculer `call` will wait for a response until it
times out and throws an error. This value can also be set by setting the `MOLECULER_TIMEOUT` environment variable.

#### transporter (default: redis://localhost)
The transporter Moleculer should use. For more information on transporters see [Transporters](https://moleculer.services/docs/0.13/networking.html#Transporters)
This value can also be set by setting the `MOLECULER_TRANSPORTER` environment variable.


## Roadmap

### 0.1 (COMPLETE)
Initial release

* Redis transporter
* Round robin load balancing
* Service registry & dynamic service discovery
* JSON serializer

### 0.2 (IN  PROGRESS)
* Fake transporter (for testing)
* Error handling, (ability to use Airbrake, etc.)
* Event grouping

### 0.3 (PENDING)
* NATS transporter
* Built in caching solution (Redis, Memory)
