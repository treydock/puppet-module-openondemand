# See README.md for more details.
class openondemand (
  $scl_packages         = $openondemand::params::scl_packages,

  # Apache
  $declare_apache       = true,

  # nginx
  $declare_nginx        = true,

  $package_ensure       = 'present',
  $package_name         = $openondemand::params::package_name,
  $service_name         = $openondemand::params::service_name,
  $service_ensure       = 'running',
  $service_enable       = true,
  $service_hasstatus    = $openondemand::params::service_hasstatus,
  $service_hasrestart   = $openondemand::params::service_hasrestart,
  $config_path          = $openondemand::params::config_path
) inherits openondemand::params {

  include openondemand::install
  include openondemand::apache
  include openondemand::config
  include openondemand::service

  anchor { 'openondemand::start': }->
  Class['openondemand::install']->
  Class['openondemand::apache']->
  Class['openondemand::config']~>
  Class['openondemand::service']->
  anchor { 'openondemand::end': }

}
