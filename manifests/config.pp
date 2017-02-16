# Private class.
class openondemand::config {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { '/etc/ood':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/ood/config':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/ood/config/clusters.d':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    purge   => true,
    recurse => true,
  }

  #Yaml_setting <| tag == 'nginx_stage' |> {
  #  target =>
  #}

  #yaml_setting { 'nginx_stage-app_root':
  #  target => '/opt/ood/nginx_stage/config/nginx_stage.yml',
  #  key    => 'app_root',
  #  value  => $openondemand::nginx_stage_app_root,
  #}

  file { '/opt/ood/nginx_stage/config/nginx_stage.yml':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('openondemand/nginx_stage.yml.erb'),
  }

  file { '/opt/ood/nginx_stage/bin/ood_ruby':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('openondemand/ood_ruby.erb'),
  }

  file { $openondemand::public_root:
    ensure => $openondemand::_public_ensure,
    target => $openondemand::_public_target,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  sudo::conf { 'ood':
    content => template('openondemand/sudo.erb')
  }

  file { '/etc/cron.d/ood':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('openondemand/ood-cron.erb'),
  }
}
