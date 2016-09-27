# Private class.
class openondemand::service {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  exec { 'nginx_stage-app_clean':
    command     => '/opt/ood/nginx_stage/sbin/nginx_stage app_clean',
    refreshonly => true,
    subscribe   => Openondemand::Install::Component['nginx_stage'],
  }->
  exec { 'nginx_stage-app_reset-pun':
    command     => '/opt/ood/nginx_stage/sbin/nginx_stage app_reset --sub-uri=/pun',
    refreshonly => true,
    subscribe   => Openondemand::Install::Component['nginx_stage'],
  }->
  exec { 'nginx_stage-nginx_clean':
    command     => '/opt/ood/nginx_stage/sbin/nginx_stage nginx_clean',
    refreshonly => true,
    subscribe   => Openondemand::Install::Component['nginx_stage'],
  }

}
