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

  if $openondemand::manage_apps_config and $openondemand::apps_config_repo {
    vcsrepo { '/opt/ood-apps-config':
      ensure   => 'latest',
      provider => 'git',
      source   => $openondemand::apps_config_repo,
      revision => $openondemand::apps_config_revision,
      user     => 'root',
      before   => File['/etc/ood/config/apps'],
    }
    $apps_config_source = "/opt/ood-apps-config/${openondemand::apps_config_repo_path}"
  } else {
    $apps_config_source = $openondemand::apps_config_source
  }

  file { '/etc/ood/config/apps':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    source  => $apps_config_source,
    recurse => true,
    purge   => true,
    force   => true,
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

  file { '/etc/ood/config/nginx_stage.yml':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('openondemand/nginx_stage.yml.erb'),
  }

  file { '/etc/ood/profile':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('openondemand/profile.erb'),
  }

  file { '/opt/ood/nginx_stage/config/nginx_stage.yml':
    ensure => 'absent',
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
