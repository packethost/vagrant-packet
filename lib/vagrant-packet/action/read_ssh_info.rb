# frozen_string_literal: true

require 'log4r'

module VagrantPlugins
  module Packet
    module Action
      # This action reads the SSH info for the machine and puts it into the
      # `:machine_ssh_info` key in the environment.
      class ReadSSHInfo
        def initialize(app, _env)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_packet::action::read_ssh_info')
        end

        def call(env)
          env[:machine_ssh_info] = read_ssh_info(env[:packet_compute], env[:machine])

          @app.call(env)
        end

        def read_ssh_info(packet, machine)
          return nil if machine.id.nil?

          # Find the machine
          server = packet.devices.get(machine.id)

          if server.nil?
            # The machine can't be found
            @logger.info("Machine couldn't be found, assuming it got destroyed.")
            machine.id = nil
            return nil
          end

          ssh_host = server.hostname

          { host: ssh_host, port: 22 }
        end
      end
    end
  end
end
