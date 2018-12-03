# Private class.
class openondemand::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # Assumes /var/www - must create since httpd24 does not
  $_web_directory_parent = dirname($openondemand::_web_directory)
  if ! defined(File[$_web_directory_parent]) {
    file { $_web_directory_parent:
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  if ! defined(File[$openondemand::_web_directory]) {
    file { $openondemand::_web_directory:
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  file { "${openondemand::_web_directory}/apps":
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { "${openondemand::_web_directory}/apps/sys":
    ensure => $openondemand::_sys_ensure,
    target => $openondemand::_sys_target,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { "${openondemand::_web_directory}/apps/usr":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
  }

  file { "${openondemand::_web_directory}/apps/dev":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
  }

  file { '/opt/ood':
    ensure => 'directory',
  }
  file { '/opt/ood/src':
    ensure => 'directory',
  }

  if ! $openondemand::_develop_mode {
    package { 'ondemand':
      ensure => $openondemand::ondemand_package_ensure
    }
    Package['ondemand'] ~> Exec['ood-portal-generator-generate']
  }

  if $openondemand::oidc_discover_uri {
    if $openondemand::_develop_mode {
      file { $openondemand::oidc_discover_root:
        ensure => 'link',
        target => $openondemand::_discover_target,
      }
    } else {
      package { 'ondemand-discover':
        ensure  => $openondemand::ood_auth_discovery_ensure,
        require => Package['ondemand'],
      }
    }
  }

  if $openondemand::register_uri {
    if $openondemand::_develop_mode {
      file { $openondemand::register_root:
        ensure => 'link',
        target => $openondemand::_register_target,
      }
    } else {
      package { 'ondemand-register':
        ensure  => $openondemand::ood_auth_registration_ensure,
        require => Package['ondemand'],
      }
    }
  }

}
