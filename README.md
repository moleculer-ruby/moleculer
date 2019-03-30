# Moleculer

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
