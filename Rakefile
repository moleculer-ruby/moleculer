# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

load "protobuf/tasks/compile.rake"

RSpec::Core::RakeTask.new(:spec)

MOLECULER_JS_VERSION      = "master"
PROTOBUF_SOURCE_URL       = "https://raw.githubusercontent.com/moleculerjs/moleculer/#{MOLECULER_JS_VERSION}" \
                            "/src/serializers/proto/packets.proto"
PROTOBUF_DESTINATION_FILE = "./tmp/protobuf/packets/packets.proto"

task default: :spec

task :compile do
  `mkdir -p ./tmp/protobuf/packets; curl #{PROTOBUF_SOURCE_URL} > #{PROTOBUF_DESTINATION_FILE}`
  ::Rake::Task["protobuf:compile"].invoke("packets", "./tmp/protobuf", "lib/moleculer/serializers/protobuf")
end
