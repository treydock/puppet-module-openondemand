# Private class.
class openondemand::apache {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $openondemand::declare_apache {
    class { '::apache':
      default_vhost  => false,
      apache_name    => 'httpd24',
      dev_packages   => ['httpd24-httpd-devel', 'httpd24-apr-devel'],
      service_name   => 'httpd24-httpd',
      apache_version => '2.4',
      httpd_dir      => '/opt/rh/httpd24/root/etc/httpd',
      server_root    => '/opt/rh/httpd24/root/etc/httpd',
      conf_dir       => '/opt/rh/httpd24/root/etc/httpd/conf',
      confd_dir      => '/opt/rh/httpd24/root/etc/httpd/conf.d',
      vhost_dir      => '/opt/rh/httpd24/root/etc/httpd/conf.d',
      mod_dir        => '/opt/rh/httpd24/root/etc/httpd/conf.modules.d',
      ports_file     => '/opt/rh/httpd24/root/etc/httpd/conf/ports.conf',
      logroot        => '/var/log/httpd24',
    }
    class { '::apache::mod::ssl':
      package_name => 'httpd24-mod_ssl',
    }
    class { '::apache::mod::php':
      package_name => 'rh-php56-php',
      template     => 'openondemand/apache/rh-php56-php.conf.erb',
      path         => 'modules/librh-php56-php5.so',
    }
    #class { '::apache::mod::passenger':
    #  mod_package => 'rh-passenger40-mod_passenger',
    #}
  } else {
    include ::apache
    include ::apache::mod::ssl
    include ::apache::mod::php
    #include ::apache::mod::passenger
  }

  ::apache::mod { 'session':
    package => 'httpd24-mod_session',
    #loadfile_name => '01-session.conf',
  }
  ::apache::mod { 'session_cookie':
    package => 'httpd24-mod_session',
    #loadfile_name => '01-session-cookie.conf',
  }
  ::apache::mod { 'session_dbd':
    package => 'httpd24-mod_session',
    #loadfile_name => '01-session-dbd.conf',
  }
  ::apache::mod { 'auth_form':
    package => 'httpd24-mod_session',
    #loadfile_name => '01-auth_form.conf',
  }
  # mod_request needed by mod_auth_form - should probably be a default module.
  ::apache::mod { 'request': }
  # xml2enc and proxy_html work around apache::mod::proxy_html lack of package name parameter
  ::apache::mod { 'xml2enc':}
  ::apache::mod { 'proxy_html':
    package => 'httpd24-mod_proxy_html',
    #loadfile_name => '00-proxyhtml.conf',
  }
  include ::apache::mod::proxy
  include ::apache::mod::proxy_http
  include ::apache::mod::proxy_connect
  # proxy_wstunnel not yet released
  #include ::apache::mod::proxy_wstunnel
  ::apache::mod { 'proxy_wstunnel': }
  # define resources normally done by apache::mod::authnz_ldap and apache::mod::ldap
  ::apache::mod { 'ldap':
    package => 'httpd24-mod_ldap',
  }
  ::apache::mod { 'authnz_ldap':
    package => 'httpd24-mod_ldap',
  }
  ::apache::mod { 'lua': }

  ::apache::custom_config { 'ood-portal':
    content        => template('openondemand/apache/ood-portal.conf.erb'),
    priority       => '10',
    verify_command => '/opt/rh/httpd24/root/usr/sbin/apachectl -t',
  }

  if $openondemand::ood_auth_type == 'openid-connect' {
    # TODO: How to handle installing this module?
    ::apache::mod { 'auth_openidc': }

    file { '/opt/rh/httpd24/root/etc/httpd/metadata':
      ensure => 'directory',
      owner  => 'root',
      group  => 'apache',
      mode   => '0750',
      before => Apache::Custom_config['auth_openidc'],
    }

    file { '/opt/rh/httpd24/root/etc/httpd/metadata/cilogon.org.client':
      ensure  => 'file',
      content => template('openondemand/apache/cilogon.org.client.erb'),
      notify  => Class['Apache::Service'],
    }
    file { '/opt/rh/httpd24/root/etc/httpd/metadata/cilogon.org.conf':
      ensure  => 'file',
      content => template('openondemand/apache/cilogon.org.conf.erb'),
      notify  => Class['Apache::Service'],
    }
    file { '/opt/rh/httpd24/root/etc/httpd/metadata/cilogon.org.provider':
      ensure  => 'file',
      content => template('openondemand/apache/cilogon.org.provider.erb'),
      notify  => Class['Apache::Service'],
    }

    ::apache::custom_config { 'auth_openidc':
      content        => template('openondemand/apache/auth_openidc.conf.erb'),
      priority       => false,
      verify_command => '/opt/rh/httpd24/root/usr/sbin/apachectl -t',
    }
    # Hack to set mode of auth_openidc.conf
    File <| title == 'apache_auth_openidc' |> {
      owner => 'root',
      group => 'apache',
      mode  => '0640',
    }
  }

}
