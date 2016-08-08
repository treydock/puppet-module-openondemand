#
define openondemand::install::component (
  $path           = "/opt/ood/src/${name}",
  $source         = undef,
  $ensure         = 'present',
  $revision       = 'master',
  $install_method = 'rake',
) {

  $_source      = pick($source, "https://github.com/OSC/${name}.git")
  $_parent_dir  = dirname($path)

  case $install_method {
    'rake': {
      $_command = 'scl enable rh-ruby22 -- rake install'
      $_notify  = Exec["install-${name}"]
    }
    default: {
      $_command = undef
      $_notify  = undef
    }
  }

  vcsrepo { $name:
    ensure   => $ensure,
    provider => 'git',
    path     => $path,
    source   => $_source,
    revision => $revision,
    require  => File[$_parent_dir],
    notify   => $_notify,
  }

  if $install_method != 'none' {
    exec { "install-${name}":
      path        => '/usr/bin:/bin:/usr/sbin:/sbin',
      cwd         => $path,
      command     => $_command,
      refreshonly => true,
    }
  }

}
