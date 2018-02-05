# Private class.
class openondemand::params ($auth_type = 'basic'){

  $nginx_stage_app_root = {
    'dev' => '~%{owner}/ondemand/dev/%{name}',
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

  case $::osfamily {
    'RedHat': {
      $package_dependencies = [
        'sqlite-devel'
      ]
      $scl_packages = [
        'rh-ruby22',
        'rh-ruby22-ruby',
        'rh-ruby22-ruby-devel',
        'rh-ruby22-ruby-doc',
        'rh-ruby22-rubygems',
        'rh-ruby22-rubygems-devel',
        'rh-ruby22-rubygem-json',
        'rh-ruby22-rubygem-rake',
        'rh-ruby22-rubygem-rdoc',
        'rh-ror41',
        'rh-ror41-rubygem-rack',
        'rh-ror41-rubygem-rails',
        'rh-ror41-rubygem-rails-doc',
        'rh-passenger40',
        'rh-passenger40-passenger',
        'rh-passenger40-passenger-doc',
        'rh-passenger40-ruby22',
        'rh-php56',
        'rh-php56-php',
        'rh-php56-php-cli',
        'rh-php56-php-mysqlnd',
        'rh-php56-php-pdo',
        'rh-php56-php-pear',
        'rh-php56-php-ldap',
        'nodejs010',
        'nginx16',
        'git19-git',
      ]
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
