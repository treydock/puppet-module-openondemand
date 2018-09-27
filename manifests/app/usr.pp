#
define openondemand::app::usr (
  $gateway_src,
  Enum['present','absent'] $ensure = 'present',
  $mode = '0750',
  $owner = 'root',
  $group = 'root',
) {

  include openondemand

  $base_web_dir = "${openondemand::_web_directory}/apps/usr"
  $web_dir      = "${base_web_dir}/${name}"
  $gateway      = "${web_dir}/gateway"

  if $ensure == 'present' {
    file { $web_dir:
      ensure => 'directory',
      owner  => $owner,
      group  => $group,
      mode   => $mode,
    }

    file { $gateway:
      ensure => 'link',
      target => $gateway_src
    }
  }

  if $ensure == 'absent' {
    file { $gateway:
      ensure => 'absent'
    } ->
    file { $web_dir:
      ensure => 'absent',
      force  => true,
    }
  }


}
