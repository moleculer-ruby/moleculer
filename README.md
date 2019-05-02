# Moleculer
[![Build Status](https://travis-ci.org/moleculer-ruby/moleculer.svg?branch=develop)](https://travis-ci.org/moleculer-ruby/moleculer)
[![Maintainability](https://api.codeclimate.com/v1/badges/d4211bbefca62cb4c10e/maintainability)](https://codeclimate.com/github/moleculer-ruby/moleculer/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/d4211bbefca62cb4c10e/test_coverage)](https://codeclimate.com/github/moleculer-ruby/moleculer/test_coverage)

Moleculer is a fast, modern and powerful microservices framework for originally written for [Node.js](). It helps you to 
build efficient, reliable & scalable services. Moleculer provides many features for building and managing your 
microservices.


## Features
- request-reply concept
- event-driven architecture with balancing
- built-in service registry & dynamic service discovery
- load balanced requests & events (round-robin, random(wip), cpu-usage(wip), latency(wip))
- supports versioned services
- built-in caching solution (memory, Redis)
- pluggable transporters (TCP, NATS, MQTT, Redis, NATS Streaming, Kafka)
- pluggable serializers (JSON, Avro, MsgPack, Protocol Buffers, Thrift)
- pluggable validator
- multiple services on a node/server
- all nodes are equal, no master/leader node


## Configuration

Moleculer is configured through the Moleculer::config method. Example:

```ruby
Moleculer.configure do |c|
  c.log_level :debug
end
```

### Configuration Options

#### log_level (default: debug)
Sets the log level of the node. defaults to `:debug`. Can be one of `:trace`, `:debug`, `:info`, `:warn`, `:error`, 
`:fatal`.

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
times out and throws an error.

#### transporter (default: redis://localhost)
The transporter Moleculer should use. For more information on transporters see [Transporters](https://moleculer.services/docs/0.13/networking.html#Transporters)
