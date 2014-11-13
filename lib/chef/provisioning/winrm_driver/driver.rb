require 'chef/provisioning/driver'
require 'chef/provisioning/convergence_strategy/install_cached'
require 'chef/provisioning/convergence_strategy/install_msi'
require 'chef/provisioning/transport/winrm'
require 'chef/provisioning/machine/windows_machine'
require 'chef/provisioning/winrm_driver/version'
require 'resolv'

class Chef
  module Provisioning
    module WinRMDriver
      # Provision machines over WinRM
      class Driver < Chef::Provisioning::Driver

        def initialize(driver_url, config)
          super
        end

        attr_reader :connection

        def self.from_url(driver_url, config)
          Driver.new(driver_url, config)
        end

        def self.canonicalize_url(driver_url, config)
          # still not exactly sure what's happening here, but it works
          url = driver_url.split(':')[1]
          [ driver_url, config ]
        end

        def allocate_machine(action_handler, machine_spec, machine_options)
          target_name = machine_spec.name

          winrm_options = validate_options(machine_options[:winrm_options])

          if !winrm_options[:ip_address].nil?
            @remote = valid_ip?(winrm_options[:ip_address])
          elsif !winrm_options[:fqdn].nil?
            @remote = valid_target?(winrm_options[:fqdn])
          else
            Chef::Log.fatal("No valid method of reaching this host!")
          end
          
          Chef::Log.debug("Using #{@remote}")

          @endpoint = winrm_endpoint(@remote, winrm_options[:winrm_port])

          # no actual allocation needed here, just need to tell the chef server stuffs
          if !machine_spec.location
            machine_spec.location = {
              'driver_url' => driver_url,
              'driver_version' => Chef::Provisioning::WinRMDriver::VERSION,
              'target_name' => target_name,
              'target_endpoint' => @endpoint,
              'allocated_at' => Time.now.utc.to_s
            }
          end

        end

        def ready_machine(action_handler, machine_spec, machine_options)
          machine_for(machine_spec, machine_options)
        end

        def machine_for(machine_spec, machine_options)
          winrm_options = machine_options[:winrm_options]
          options = {
            :user => winrm_options[:winrm_user],
            :pass => winrm_options[:winrm_pass],
            :disable_sspi => true,
            :basic_auth_only => true
          }
          type = :plaintext
          transport = Chef::Provisioning::Transport::WinRM.new(@endpoint, type, options, config)
          convergence_strategy = convergence_for(machine_options[:convergence_options], config)
          Chef::Provisioning::Machine::WindowsMachine.new(machine_spec, transport, convergence_strategy)
        end

        def destroy_machine(action_handler, machine_spec, machine_options)
          action_handler.perform_action "Removing machine #{machine_spec.name}" do
            machine_spec.location = nil
          end
          strategy = convergence_for(machine_options[:convergence_options],config)
          strategy.cleanup_convergence(action_handler, machine_spec)
          Chef::Log.debug("#{machine_spec.name} removed from the Chef server")
        end

        def stop_machine(action_handler, machine_spec, machine_options)
          Chef::Log.warn("Machine action :stop is unsupported")
        end

        def connect_to_machine(machine_spec, machine_options)
          machine_for(machine_spec, machine_options)
        end

        def validate_options(machine_options)
          valid_machine_options = %w{
            ip_address
            fqdn
            winrm_port
            timeout
            winrm_user
            winrm_pass
          }
          machine_options.each { |k,v| Chef::Log.fatal("Invalid machine option! #{k}") unless valid_machine_options.include?(k.to_s) }
          
          # set some defaults
          machine_options[:winrm_user] ||= 'Administrator'
          machine_options[:winrm_pass] ||= ''
          machine_options[:winrm_port] ||= 5985

          machine_options
        end

        def valid_ip?(address)
          !!Resolv::AddressRegex.match(address) || Chef::Log.fatal("You've given me an invalid IP address! #{address}")
          address
        end

        def valid_target?(fqdn)
          begin
            Resolv.getaddress(fqdn)
          rescue
            Chef::Log.fatal("Unable to resolve target! #{fqdn}")
          end
        end

        def winrm_endpoint(fqdn, port)
          endpoint = "http://#{fqdn}:#{port}/wsman"
          Chef::Log.debug("Using #{endpoint} endpoint")
          endpoint
        end

        def convergence_for(convergence_options, config)
          Chef::Provisioning::ConvergenceStrategy::InstallMsi.new(convergence_options, config)
        end

      end
    end
  end
end






