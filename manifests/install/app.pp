#
define openondemand::install::app (
  String $ensure = 'present',
  String $package = "ondemand-${name}",
  Boolean $manage_package = true,
  Optional[Stdlib::Absolutepath] $path = undef,
  String $owner = 'root',
  String $group = 'root',
  String $mode  = '0755',
) {

  include openondemand

  $_path = pick($path, "${openondemand::_web_directory}/apps/sys/${name}")

  if $manage_package {
    ensure_resource('package', $package, {
      'ensure'  => $ensure,
      'require' => Package['ondemand'],
    })
  }

  file { $_path:
    ensure  => 'directory',
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    require => Package[$package],
  }

}
