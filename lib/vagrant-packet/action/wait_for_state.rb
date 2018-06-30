# frozen_string_literal: true

require 'log4r'
require 'timeout'

module VagrantPlugins
  module Packet
    module Action
      # This action will wait for a machine to reach a specific state or quit by timeout
      class WaitForState
        # env[:result] will be false in case of timeout.
        # @param [Symbol] state Target machine state.
        # @param [Number] timeout Timeout in seconds.
        def initialize(app, _env, state, timeout)
          @app     = app
          @logger  = Log4r::Logger.new('vagrant_packet::action::wait_for_state')
          @state   = state
          @timeout = timeout
        end

        def call(env)
          env[:result] = true
          if env[:machine].state.id == @state
            @logger.info(I18n.t('vagrant_packet.already_status', status: @state))
          else
            @logger.info("Waiting for machine to reach state #{@state}")
            begin
              Timeout.timeout(@timeout) do
                sleep 2 until env[:machine].state.id == @state
              end
            rescue Timeout::Error
              env[:result] = false # couldn't reach state in time
            end
          end

          @app.call(env)
        end
      end
    end
  end
end
