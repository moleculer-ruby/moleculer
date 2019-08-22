# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

require_relative "lib/moleculer/tasks/compile_protobuf"

RSpec::Core::RakeTask.new(:spec)



task default: :spec

task :compile do
  Moleculer::Tasks::CompileProtobuf.start
end
