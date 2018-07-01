# frozen_string_literal: true

require 'log4r'
require 'json'

module VagrantPlugins
  module Packet
    module Action
      # This terminates the running instance.
      class TerminateInstance
        def initialize(app, _env)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_packet::action::terminate_instance')
        end

        def call(env)
          server = env[:packet_compute].devices.get(env[:machine].id)

          # Destroy the server and remove the tracking ID
          env[:ui].info(I18n.t('vagrant_packet.terminating'))
          begin
            server.destroy
            env[:machine].id = nil
          rescue Exception => e
            env[:ui].info(I18n.t('vagrant_packet.terminate_while_provisioning'))
          end

          @app.call(env)
        end
      end
    end
  end
end
