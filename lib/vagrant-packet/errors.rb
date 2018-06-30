# frozen_string_literal: true

require 'vagrant'

module VagrantPlugins
  module Packet
    module Errors
      class VagrantPacketError < Vagrant::Errors::VagrantError
        error_namespace('vagrant_packet.errors')
      end

      class FogError < VagrantPacketError
        error_key(:fog_error)
      end

      class InternalFogError < VagrantPacketError
        error_key(:internal_fog_error)
      end

      class InstanceReadyTimeout < VagrantPacketError
        error_key(:instance_ready_timeout)
      end

      class InstancePackageError < VagrantPacketError
        error_key(:instance_package_error)
      end

      class InstancePackageTimeout < VagrantPacketError
        error_key(:instance_package_timeout)
      end

      class RsyncError < VagrantPacketError
        error_key(:rsync_error)
      end

      class MkdirError < VagrantPacketError
        error_key(:mkdir_error)
      end
    end
  end
end
