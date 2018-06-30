require "log4r"

module VagrantPlugins
  module Packet
    module Action
      # This stops the running instance.
      class StopInstance
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_packet::action::stop_instance")
        end

        def call(env)
          server = env[:packet_compute].devices.get(env[:machine].id)

          if env[:machine].state.id == :stopped
            env[:ui].info(I18n.t("vagrant_packet.already_status", :status => env[:machine].state.id))
          else
            env[:ui].info(I18n.t("vagrant_packet.stopping"))
            server.stop
          end

          @app.call(env)
        end
      end
    end
  end
end
