require 'chef/provisioning/winrm_driver/driver'

Chef::Provisioning.register_driver_class("winrm", Chef::Provisioning::WinRMDriver::Driver)