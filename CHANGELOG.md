# 0.2.0

### Features

* **actions:** ability to process errors that occur when executing actions 
  ([9a3f36d](https://github.com/moleculer-ruby/moleculer/commit/9a3f36d))
* **events:** add ability to rescue from event errors and  handle 
  ([0f2cf1a](https://github.com/moleculer-ruby/moleculer/commit/0f2cf1a))
* **fake transporter:** add fake transporter that can be used without dependencies on an actual connected transporter
* **broker:** add the ability to check if a borker is started through the `#started` method

### Bugfixes
* fix `concurrent_ruby` version requirement to ensure at least `1.1` is required
* fix an issue where heartbeats back up in the queue and cause errors when consumed

#  0.1.1

### Bugfixes
* fixes bug where event publishing uses the wrong method name to look up local events
* fixes condition where events may double publish when multiple events are registered
