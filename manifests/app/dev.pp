#
define openondemand::app::dev (
  Enum['present','absent'] $ensure = 'present',
  $mode = '0755',
  $owner = 'root',
  $group = 'root',
  $home_subdir = 'ondemand/dev',
  $gateway_src = undef,
) {

  include openondemand

  $base_web_dir = "${openondemand::_web_directory}/apps/dev"
  $web_dir      = "${base_web_dir}/${name}"
  $gateway      = "${web_dir}/gateway"
  $_gateway_src  = pick($gateway_src, "~${name}/${home_subdir}")

  if $ensure == 'present' {
    file { $web_dir:
      ensure => 'directory',
      owner  => $owner,
      group  => $group,
      mode   => $mode,
    }

    exec { "openondemand::app::dev-link-gateway-${name}":
      path    => '/usr/bin:/bin:/usr/sbin:/sbin',
      command => "ln -snf ${_gateway_src} ${gateway}",
      unless  => [
        "test -L ${gateway}",
        "readlink ${gateway} | grep -q ${_gateway_src}",
      ],
      require => File[$web_dir],
    }
  }

  if $ensure == 'absent' {
    exec { "openondemand::app::dev-unlink-gateway-${name}":
      path    => '/usr/bin:/bin:/usr/sbin:/sbin',
      command => "unlink ${gateway}",
      onlyif  => "test -L ${gateway}",
      before  => File[$web_dir]
    }
    file { $web_dir:
      ensure => 'absent',
      force  => true,
    }
  }


}
