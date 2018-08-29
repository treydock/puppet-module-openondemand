#
define openondemand::app::usr (
  Enum['present','absent'] $ensure = 'present',
  $mode = '0750',
  $owner = 'root',
  $group = 'root',
  $home_subdir = 'ood/share',
) {

  include openondemand

  $base_web_dir = "${openondemand::_web_directory}/apps/usr"
  $web_dir      = "${base_web_dir}/${name}"
  $gateway      = "${web_dir}/gateway"
  $gateway_src  = "~${name}/${home_subdir}"

  if $ensure == 'present' {
    file { $web_dir:
      ensure => 'directory',
      owner  => $owner,
      group  => $group,
      mode   => $mode,
    }

    exec { "openondemand::app::usr-link-gateway-${name}":
      path    => '/usr/bin:/bin:/usr/sbin:/sbin',
      command => "ln -s ${gateway_src} ${gateway}",
      unless  => "test -L ${gateway}",
      require => File[$web_dir]
    }
  }

  if $ensure == 'absent' {
    exec { "openondemand::app::usr-unlink-gateway-${name}":
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
