# Private class
class openondemand::app::installer {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $openondemand::manage_app_installer {
    vcsrepo { 'ood-apps-installer':
      ensure   => $openondemand::_app_installer_ensure,
      provider => 'git',
      path     => '/opt/ood/src/apps',
      source   => 'https://github.com/OSC/ood-apps-installer.git',
      revision => $openondemand::app_installer_revision,
      require  => File['/opt/ood'],
      notify   => [
        Exec['ood-apps-installer-rake'],
      ],
    }

    exec { 'ood-apps-installer-rake':
      path        => '/usr/bin:/bin:/usr/sbin:/sbin',
      environment => $openondemand::default_sshhost_env,
      cwd         => '/opt/ood/src/apps',
      command     => 'scl enable rh-ruby22 nodejs010 git19 -- rake HOME=$(mktemp -d)',
      logoutput   => true,
      refreshonly => true,
      timeout     => 1200,
    }
    ~>exec { 'ood-apps-installer-rake-install':
      path        => '/usr/bin:/bin:/usr/sbin:/sbin',
      cwd         => '/opt/ood/src/apps',
      command     => 'scl enable rh-ruby22 -- rake install',
      logoutput   => true,
      refreshonly => true,
    }
  }

}
