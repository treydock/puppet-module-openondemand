# Private class.
class openondemand::params ($auth_type = 'basic'){

  $nginx_stage_app_root = {
    'dev' => '/var/www/ood/apps/dev/%{owner}/gateway/%{name}',
    'usr' => '/var/www/ood/apps/usr/%{owner}/gateway/%{name}',
    'sys' => '/var/www/ood/apps/sys/%{name}',
  }

  $basic_auth_users = {
    'ood' => { 'password' => 'ood' },
  }

  $auth_configs = [
    'AuthName "Private"',
    'AuthUserFile "/opt/rh/httpd24/root/etc/httpd/.htpasswd"',
    'RequestHeader unset Authorization',
    'Require valid-user',
  ]

  $base_apps = {
    'dashboard' => { 'package' => 'ondemand', 'manage_package' => false },
    'shell' => { 'package' => 'ondemand', 'manage_package' => false },
    'files' => { 'package' => 'ondemand', 'manage_package' => false },
    'file-editor' => { 'package' => 'ondemand', 'manage_package' => false },
    'activejobs' => { 'package' => 'ondemand', 'manage_package' => false },
    'myjobs' => { 'package' => 'ondemand', 'manage_package' => false },
    'bc_desktop' => { 'package' => 'ondemand', 'manage_package' => false },
  }

  case $::osfamily {
    'RedHat': {
      if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
        $apache_dev_packages = ['httpd24-httpd-devel', 'apr-devel']
      } elsif versioncmp($::operatingsystemrelease, '6.0') >= 0 {
        $apache_dev_packages = ['httpd24-httpd-devel', 'httpd24-apr-devel']
      } else {
        fail("Unsupported operatingsystemmajrelease ${::operatingsystemmajrelease}, module ${module_name} only supports 6 or 7 for osfamily RedHat") # lint:ignore:140chars
      }
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
