# Private class.
class openondemand::params {

  case $::osfamily {
    'RedHat': {
      if $::operatingsystemmajrelease == '6' {
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
        ]
      } else {
        fail("Unsupported operatingsystemmajrelease ${::operatingsystemmajrelease}, module ${module_name} only supports 6 for osfamily RedHat")
      }
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
