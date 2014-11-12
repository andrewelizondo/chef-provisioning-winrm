$:.unshift(File.dirname(__FILE__) + '/lib')
require 'chef/provisioning/winrm_driver/version'

Gem::Specification.new do |s|
	s.name = 'chef-provisioning-winrm'
	s.version = Chef::Provisioning::WinRMDriver::VERSION
	s.platform = Gem::Platform::RUBY
	s.extra_rdoc_files = ['LICENSE']
	s.summary = 'Provisioner for existing windows infrastructure over WinRM'
	s.description = s.summary
	s.author = 'Andre Elizondo'
	s.email = 'andre@getchef.com'
	s.homepage = 'https://github.com/andrewelizondo/chef-provisioning-winrm'

	s.add_dependency 'chef', '>= 0'
	s.add_dependency 'chef-provisioning', '>= 0'
	s.add_dependency 'winrm', '>= 0'
	
	s.add_development_dependency 'rspec', '>= 0'
	s.add_development_dependency 'rake', '>= 0'

	s.bindir				= "bin"
	s.executables		= %w()

	s.require_path 	= 'lib'
	s.files = %w(Rakefile LICENSE README.md) + Dir.glob("{distro,lib,tasks,spec}/**/*", File::FNM_DOTMATCH).reject {|f| File.directory?(f) }
end
