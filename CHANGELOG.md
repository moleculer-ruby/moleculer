## 0.2.0
### Breaking Changes
* `rescue_event` and `rescue_action` have been removed and replaced with a more generic `rescue_from`
  handler
 
### Features
* add a fake transporter that can be used for testing without dependencies on an
  actual connected transporter
* `log_level`, `transporter`, `heartbeat_interval`, `log_file` and `timeout` are now configurable
  via environment variable prefixed with `MOLECULER_`
* added `rescue_from` configuration. this replaces `rescue_event` and `rescue_action`.
* updated json to 2.2.0
* updated oj to 3.7.12
* updated redis to 4.1.2
* updated yard to 0.9.20
* updated rspec-support to 3.8.2
* updated ruby-progressbar to 1.10.1
* updated rspec-mocks to 3.8.1
* updated simplecov to 0.17.0
* updated rspec-core to 3.8.2
* updated rubocop to 0.74.0
  
### Bugfixes
* fix `concurrent_ruby` version requirement to ensure at least `1.1` is required.

##  0.1.1
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
