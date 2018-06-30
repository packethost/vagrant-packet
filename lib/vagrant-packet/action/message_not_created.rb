# frozen_string_literal: true

module VagrantPlugins
  module Packet
    module Action
      class MessageNotCreated
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t('vagrant_packet.not_created'))
          @app.call(env)
        end
      end
    end
  end
end
