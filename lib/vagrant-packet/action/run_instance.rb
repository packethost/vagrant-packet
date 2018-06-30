# frozen_string_literal: true

require 'log4r'
require 'json'

require 'vagrant/util/retryable'

require 'vagrant-packet/util/timer'

module VagrantPlugins
  module Packet
    module Action
      # This runs the configured instance.
      class RunInstance
        include Vagrant::Util::Retryable

        def initialize(app, _env)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_packet::action::run_instance')
        end

        def call(env)
          # Initialize metrics if they haven't been
          env[:metrics] ||= {}

          # Get the configs
          machine = env[:machine]

          # Launch!
          env[:ui].info(I18n.t('vagrant_packet.launching_instance'))
          env[:ui].info(" -- Project: #{machine.provider_config.project_id}")
          env[:ui].info(" -- Facility: #{machine.provider_config.facility}")
          env[:ui].info(" -- OS: #{machine.provider_config.operating_system}")
          env[:ui].info(" -- Machine: #{machine.provider_config.plan}")

          options = {
            project_id:               machine.provider_config.project_id,
            hostname:                 machine.provider_config.hostname,
            plan:                     machine.provider_config.plan,
            facility:                 machine.provider_config.facility,
            operating_system:         machine.provider_config.operating_system,
            description:              machine.provider_config.description,
            billing_cycle:            machine.provider_config.billing_cycle,
            always_pxe:               machine.provider_config.always_pxe,
            ipxe_script_url:          machine.provider_config.ipxe_script_url,
            userdata:                 machine.provider_config.userdata,
            locked:                   machine.provider_config.locked,
            hardware_reservation_id:  machine.provider_config.hardware_reservation_id,
            spot_instance:            machine.provider_config.spot_instance,
            spot_price_max:           machine.provider_config.spot_price_max,
            termination_time:         machine.provider_config.termination_time,
            tags:                     machine.provider_config.tags,
            project_ssh_keys:         machine.provider_config.project_ssh_keys,
            user_ssh_keys:            machine.provider_config.user_ssh_keys,
            features:                 machine.provider_config.features
          }

          begin
            server = env[:packet_compute].devices.create(options)
          rescue Fog::Compute::Packet::NotFound => e
            # Invalid subnet doesn't have its own error so we catch and
            # check the error message here.
            raise(Errors::FogError, message: "Subnet ID not found: #{subnet_id}") if e.message match?(/subnet ID/)
          rescue Fog::Compute::Packet::Error => e
            raise(Errors::FogError, message: e.message)
          rescue Excon::Errors::HTTPStatusError => e
            raise(Errors::InternalFogError, error: e.message, response: e.response.body)
          end

          # Immediately save the ID since it is created at this point.
          env[:machine].id = server.id

          # Wait for the instance to be ready first
          env[:metrics]['instance_ready_time'] = Util::Timer.time do
            tries = machine.provider_config.instance_ready_timeout / 2

            env[:ui].info(I18n.t('vagrant_packet.waiting_for_ready'))
            begin
              retryable(on: Fog::Errors::TimeoutError, tries: tries) do
                # If we're interrupted don't worry about waiting
                next if env[:interrupted]

                # Wait for the server to be ready
                server.wait_for(2, machine.provider_config.instance_check_interval) { ready? }
              end
            rescue Fog::Errors::TimeoutError
              # Delete the instance
              terminate(env)

              # Notify the user
              raise(Errors::InstanceReadyTimeout, timeout: machine.provider_config.instance_ready_timeout)
            end
          end

          @logger.info("Time to instance ready: #{env[:metrics]['instance_ready_time']}")

          unless env[:interrupted]
            env[:metrics]['instance_ssh_time'] = Util::Timer.time do
              # Wait for SSH to be ready.
              env[:ui].info(I18n.t('vagrant_packet.waiting_for_ssh'))
              network_ready_retries = 0
              network_ready_retries_max = 10
              # rubocop:disable Lint/LiteralAsCondition
              while true
                # If we're interrupted then just back out
                break if env[:interrupted]
                # When a packet device comes up, it's networking may not be ready
                # by the time we connect.
                begin
                  break if env[:machine].communicate.ready?
                rescue Exception => e
                  if network_ready_retries < network_ready_retries_max
                    network_ready_retries += 1
                    @logger.warn(I18n.t('vagrant_packet.waiting_for_ssh, retrying'))
                  else
                    raise e
                  end
                end
                sleep 2
              end
              # rubocop:enable Lint/LiteralAsCondition
            end

            @logger.info("Time till SSH ready: #{env[:metrics]['instance_ssh_time']}")

            # Ready and booted!
            env[:ui].info(I18n.t('vagrant_packet.ready'))
          end

          # Terminate the instance if we were interrupted
          terminate(env) if env[:interrupted]

          @app.call(env)
        end

        def recover(env)
          return if env['vagrant.error'].is_a?(Vagrant::Errors::VagrantError)
          terminate(env) if env[:machine].provider.state.id != :not_created
        end

        def terminate(env)
          destroy_env = env.dup
          destroy_env.delete(:interrupted)
          destroy_env[:config_validate] = false
          destroy_env[:force_confirm_destroy] = true
          env[:action_runner].run(Action.action_destroy, destroy_env)
        end
      end
    end
  end
end
