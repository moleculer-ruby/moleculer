# CHANGELOG

## 0.2.0
### Features
* add a fake transporter that can be used for testing without dependencies on an
  actual connected transporter
  
### Bugfixes
* fix `concurrent_ruby` version requirement to ensure at least `1.1` is required.

##  0.1.1

### Bugfixes
* fixes bug where event publishing uses the wrong method name to look up local events
* fixes condition where events may double publish when multiple events are registered
