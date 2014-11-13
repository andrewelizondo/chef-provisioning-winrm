# chef-provisioning-winrm

Partially working but still a WIP, currently able to bootstrap machines over winrm using http.

**Note:** Windows with Chef provisioning is currently only usable with a hosted/on-premise chef server, chef-zero will not work here. :(

## Installation

Clone this repository.

	$ git clone https://github.com/andrewelizondo/chef-provisioning-winrm.git

Build the gem.

	$ gem build chef-provisioning-winrm.gemspec

**Note** If you're using ChefDK, this should be installed under the ChefDK Ruby using `chef gem <build|install>`


Install the gem.

	$ sudo gem install chef-provisioning-winrm-0.1.1.gem

## Usage

* required machine options: only one is required

  :ip\_address,
  :fqdn

* valid options:

	:winrm\_user, - defaults to Administrator
	:winrm\_pass, - defaults to an empty string
	:winrm\_port, - defaults to 5985

## Example

```ruby

		require 'chef/provisioning/winrm_driver'

		with_driver 'winrm'

		with_chef_server 'https://api.opscode.com/organizations/<your_org>',{
			:client_name => Chef::Config[:node_name],
			:signing_key_filename => Chef::Config[:client_key]
		}

		machine 'what-do' do
			action [:converge]
			machine_options :winrm_options => {
				:winrm_user => 'vagrant',
				:winrm_pass => 'vagrant',
				:winrm_port => '5985',
				:ip_address => '192.168.243.198'
			}
			role 'win_base'
		end
```