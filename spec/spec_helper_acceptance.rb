require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

dir = File.expand_path(File.dirname(__FILE__))
Dir["#{dir}/acceptance/shared_examples/**/*.rb"].sort.each {|f| require f}

run_puppet_install_helper
install_module_on(hosts)
install_module_dependencies_on(hosts)

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  c.before :suite do
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-inifile'), { :acceptable_exit_codes => [0,1] }
      puppet_pp = <<-EOF
      ini_setting { 'puppet.conf/main/show_diff':
        ensure  => 'present',
        section => 'main',
        path    => '/etc/puppetlabs/puppet/puppet.conf',
        setting => 'show_diff',
        value   => 'true',
      }
      EOF
      apply_manifest_on(host, puppet_pp, :catch_failures => true)
    end
  end
end
