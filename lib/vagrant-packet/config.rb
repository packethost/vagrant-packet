# frozen_string_literal: true

require 'vagrant'

module VagrantPlugins
  module Packet
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :packet_token
      attr_accessor :instance_ready_timeout
      attr_accessor :instance_check_interval
      attr_accessor :project_id
      attr_accessor :hostname
      attr_accessor :plan
      attr_accessor :facility
      attr_accessor :operating_system
      attr_accessor :description
      attr_accessor :billing_cycle
      attr_accessor :always_pxe
      attr_accessor :ipxe_script_url
      attr_accessor :userdata
      attr_accessor :locked
      attr_accessor :hardware_reservation_id
      attr_accessor :spot_instance
      attr_accessor :spot_price_max
      attr_accessor :termination_time
      attr_accessor :tags
      attr_accessor :project_ssh_keys
      attr_accessor :user_ssh_keys
      attr_accessor :features

      def initialize
        @packet_token             = UNSET_VALUE
        @instance_ready_timeout   = UNSET_VALUE
        @instance_check_interval  = UNSET_VALUE
        @project_id               = UNSET_VALUE
        @hostname                 = UNSET_VALUE
        @plan                     = UNSET_VALUE
        @facility                 = UNSET_VALUE
        @operating_system         = UNSET_VALUE
        @description              = UNSET_VALUE
        @billing_cycle            = UNSET_VALUE
        @always_pxe               = UNSET_VALUE
        @ipxe_script_url          = UNSET_VALUE
        @userdata                 = UNSET_VALUE
        @locked                   = UNSET_VALUE
        @hardware_reservation_id  = UNSET_VALUE
        @spot_instance            = UNSET_VALUE
        @spot_price_max           = UNSET_VALUE
        @termination_time         = UNSET_VALUE
        @tags                     = UNSET_VALUE
        @project_ssh_keys         = UNSET_VALUE
        @user_ssh_keys            = UNSET_VALUE
        @features                 = UNSET_VALUE
      end

      def finalize!
        @packet_token             = nil if @packet_token == UNSET_VALUE
        @instance_ready_timeout   = 600 if @instance_ready_timeout == UNSET_VALUE
        @instance_check_interval  = 10 if @instance_check_interval == UNSET_VALUE
        @project_id               = nil if @project_id == UNSET_VALUE
        @hostname                 = nil if @hostname == UNSET_VALUE
        @plan                     = nil if @plan == UNSET_VALUE
        @facility                 = nil if @facility == UNSET_VALUE
        @operating_system         = 'ubuntu_16_04' if @operating_system == UNSET_VALUE
        @description              = nil if @description == UNSET_VALUE
        @billing_cycle            = nil if @billing_cycle == UNSET_VALUE
        @always_pxe               = nil if @always_pxe == UNSET_VALUE
        @ipxe_script_url          = nil if @ipxe_script_url == UNSET_VALUE
        @userdata                 = nil if @userdata == UNSET_VALUE
        @locked                   = nil if @locked == UNSET_VALUE
        @hardware_reservation_id  = nil if @hardware_reservation_id == UNSET_VALUE
        @spot_instance            = nil if @spot_instance == UNSET_VALUE
        @spot_price_max           = nil if @spot_price_max == UNSET_VALUE
        @termination_time         = nil if @termination_time == UNSET_VALUE
        @tags                     = nil if @tags == UNSET_VALUE
        @project_ssh_keys         = nil if @project_ssh_keys == UNSET_VALUE
        @user_ssh_keys            = nil if @user_ssh_keys == UNSET_VALUE
        @features                 = nil if @features == UNSET_VALUE
      end
    end
  end
end
