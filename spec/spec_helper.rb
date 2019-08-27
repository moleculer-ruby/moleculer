require "bundler/setup"
require "moleculer"
require "simplecov"
require "timecop"

# Turn off logging for specs
ENV["MOLECULER_LOG_FILE"] = "/dev/null"
load File.expand_path("../lib/moleculer/configuration.rb", __dir__)


RSpec.configure do |config|
  SimpleCov.start

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec.shared_examples "base s"
