# frozen_string_literal: true

require "rspec"
require "bundler/setup"
require "moleculer"
require "simplecov"

RSpec.configure do |config|
  SimpleCov.start

  SemanticLogger.add_appender(io: $stdout, formatter: :color)
  SemanticLogger.default_level = :trace


  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
