# frozen_string_literal: true

##
# This file is auto-generated. DO NOT EDIT!
#
require "protobuf"

module Moleculer
  module Serializers
    module Protobuf
      module Packets
        ::Protobuf::Optionable.inject(self) { ::Google::Protobuf::FileOptions }

        ##
        # Message Classes
        #
        class PacketEvent < ::Protobuf::Message; end
        class PacketRequest < ::Protobuf::Message; end
        class PacketResponse < ::Protobuf::Message; end
        class PacketDiscover < ::Protobuf::Message; end
        class PacketInfo < ::Protobuf::Message
          class Client < ::Protobuf::Message; end
        end

        class PacketDisconnect < ::Protobuf::Message; end
        class PacketHeartbeat < ::Protobuf::Message; end
        class PacketPing < ::Protobuf::Message; end
        class PacketPong < ::Protobuf::Message; end
        class PacketGossipHello < ::Protobuf::Message; end
        class PacketGossipRequest < ::Protobuf::Message; end
        class PacketGossipResponse < ::Protobuf::Message; end

        ##
        # Message Fields
        #
        class PacketEvent
          optional :string, :ver, 1
          optional :string, :sender, 2
          optional :string, :event, 3
          optional :string, :data, 4
          repeated :string, :groups, 5
          optional :bool, :broadcast, 6
        end

        class PacketRequest
          optional :string, :ver, 1
          optional :string, :sender, 2
          optional :string, :id, 3
          optional :string, :action, 4
          optional :bytes, :params, 5
          optional :string, :meta, 6
          optional :double, :timeout, 7
          optional :int32, :level, 8
          optional :bool, :metrics, 9
          optional :string, :parentID, 10
          optional :string, :requestID, 11
          optional :bool, :stream, 12
        end

        class PacketResponse
          optional :string, :ver, 1
          optional :string, :sender, 2
          optional :string, :id, 3
          optional :bool, :success, 4
          optional :bytes, :data, 5
          optional :string, :error, 6
          optional :string, :meta, 7
          optional :bool, :stream, 8
        end

        class PacketDiscover
          optional :string, :ver, 1
          optional :string, :sender, 2
        end

        class PacketInfo
          class Client
            optional :string, :type, 1
            optional :string, :version, 2
            optional :string, :langVersion, 3
          end

          optional :string, :ver, 1
          optional :string, :sender, 2
          optional :string, :services, 3
          optional :string, :config, 4
          repeated :string, :ipList, 5
          optional :string, :hostname, 6
          optional ::Moleculer::Serializers::Protobuf::Packets::PacketInfo::Client, :client, 7
          optional :int32, :seq, 8
        end

        class PacketDisconnect
          optional :string, :ver, 1
          optional :string, :sender, 2
        end

        class PacketHeartbeat
          optional :string, :ver, 1
          optional :string, :sender, 2
          optional :double, :cpu, 3
        end

        class PacketPing
          optional :string, :ver, 1
          optional :string, :sender, 2
          optional :int64, :time, 3
        end

        class PacketPong
          optional :string, :ver, 1
          optional :string, :sender, 2
          optional :int64, :time, 3
          optional :int64, :arrived, 4
        end

        class PacketGossipHello
          optional :string, :ver, 1
          optional :string, :sender, 2
          optional :string, :host, 3
          optional :int32, :port, 4
        end

        class PacketGossipRequest
          optional :string, :ver, 1
          optional :string, :sender, 2
          optional :string, :online, 3
          optional :string, :offline, 4
        end

        class PacketGossipResponse
          optional :string, :ver, 1
          optional :string, :sender, 2
          optional :string, :online, 3
          optional :string, :offline, 4
        end
      end
    end
  end
end
