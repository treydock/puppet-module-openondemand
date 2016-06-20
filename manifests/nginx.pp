# Private class.
class openondemand::nginx {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $openondemand::declare_nginx {
    class { '::nginx':
      package_name => 'nginx16',
      manage_repo  => false,
      #conf_dir     => '/opt/rh/nginx16/root/etc/nginx',
      #pid          => '/opt/rh/nginx16/root/var/run/nginx/nginx.pid',
      #logdir       => '/var/log/nginx16',
      #run_dir      => '/opt/rh/nginx16/root/var/run',
      service_name => 'nginx16-nginx',
    }
  } else {
    include ::nginx
  }

}
