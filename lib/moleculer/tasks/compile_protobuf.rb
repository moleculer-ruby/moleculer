# frozen_string_literal: true

require "thor/group"
require "thor/actions"

load "protobuf/tasks/compile.rake"

module Moleculer
  module Tasks
    ##
    # Downloads and compiles protobuf definitions
    class CompileProtobuf < Thor::Group
      include Thor::Actions

      MOLECULER_JS_VERSION      = "master"
      PROTOBUF_SOURCE_URL       = "https://raw.githubusercontent.com/moleculerjs/moleculer/#{MOLECULER_JS_VERSION}" \
                                "/src/serializers/proto/packets.proto"
      PROTOBUF_DESTINATION_FILE = "./tmp/protobuf/packets/packets.proto"

      def make_temp_directory
        empty_directory File.dirname(PROTOBUF_DESTINATION_FILE)
      end

      def download_protobuf
        run "curl #{PROTOBUF_SOURCE_URL} > #{PROTOBUF_DESTINATION_FILE}"
      end

      def update_namespace
        gsub_file PROTOBUF_DESTINATION_FILE, "package packets;", "package moleculer.serializers.protobuf.packets;"
      end

      def compile_protobuf
        ::Rake::Task["protobuf:compile"].invoke("packets", "./tmp/protobuf", "lib/moleculer/serializers/protobuf")
      end
    end
  end
end

