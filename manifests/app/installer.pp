# Private class
class openondemand::app::installer {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $openondemand::manage_app_installer {
    if $openondemand::install_bc_desktop {
      $bc_desktop_notify_exec = Exec['ood-apps-installer-rake-build-bc_desktop']
    } else {
      $bc_desktop_notify_exec = undef
    }
    $installer_notify = delete_undef_values([
      Exec['ood-apps-installer-rake'],
      $bc_desktop_notify_exec
    ])

    vcsrepo { 'ood-apps-installer':
      ensure   => $openondemand::_app_installer_ensure,
      provider => 'git',
      path     => '/opt/ood/src/apps',
      source   => 'https://github.com/OSC/ood-apps-installer.git',
      revision => $openondemand::app_installer_revision,
      require  => File['/opt/ood'],
      notify   => $installer_notify,
    }

    exec { 'ood-apps-installer-rake':
      path        => '/usr/bin:/bin:/usr/sbin:/sbin',
      environment => $openondemand::app_installer_env,
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

    if $openondemand::install_bc_desktop {
      exec { 'ood-apps-installer-rake-build-bc_desktop':
        path        => '/usr/bin:/bin:/usr/sbin:/sbin',
        environment => $openondemand::app_installer_env,
        cwd         => '/opt/ood/src/apps',
        command     => 'scl enable rh-ruby22 nodejs010 git19 -- rake build:bc_desktop HOME=$(mktemp -d)',
        logoutput   => true,
        refreshonly => true,
        timeout     => 1200,
        require     => [
          Exec['ood-apps-installer-rake'],
          Exec['ood-apps-installer-rake-install']
        ],
      }
      ~>exec { 'ood-apps-installer-rake-install-bc_desktop':
        path        => '/usr/bin:/bin:/usr/sbin:/sbin',
        cwd         => '/opt/ood/src/apps',
        command     => 'scl enable rh-ruby22 -- rake install:bc_desktop',
        logoutput   => true,
        refreshonly => true,
      }
    }
  }

}
