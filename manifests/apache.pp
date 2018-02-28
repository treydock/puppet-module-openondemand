# Private class.
class openondemand::apache {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $openondemand::declare_apache {
    class { '::apache':
      default_vhost  => false,
      apache_name    => 'httpd24',
      dev_packages   => $openondemand::params::apache_dev_packages,
      service_name   => 'httpd24-httpd',
      apache_version => '2.4',
      httpd_dir      => '/opt/rh/httpd24/root/etc/httpd',
      server_root    => '/opt/rh/httpd24/root/etc/httpd',
      conf_dir       => '/opt/rh/httpd24/root/etc/httpd/conf',
      confd_dir      => '/opt/rh/httpd24/root/etc/httpd/conf.d',
      vhost_dir      => '/opt/rh/httpd24/root/etc/httpd/conf.d',
      mod_dir        => '/opt/rh/httpd24/root/etc/httpd/conf.modules.d',
      ports_file     => '/opt/rh/httpd24/root/etc/httpd/conf/ports.conf',
      ssl_file       => '/opt/rh/httpd24/root/etc/httpd/conf.d/ssl.conf',
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
  include ::apache::mod::headers

  if $openondemand::auth_type in ['cilogon', 'openid-connect'] {
    ::apache::mod { 'auth_openidc':
      package        => 'httpd24-mod_auth_openidc',
      package_ensure => $openondemand::mod_auth_openidc_ensure,
    }

    file { '/opt/rh/httpd24/root/etc/httpd/metadata':
      ensure  => 'directory',
      owner   => 'root',
      group   => 'apache',
      mode    => '0750',
      recurse => true,
      purge   => true,
      before  => Apache::Custom_config['auth_openidc'],
    }

    ::apache::custom_config { 'auth_openidc':
      content        => template('openondemand/apache/auth_openidc.conf.erb'),
      priority       => false,
      verify_command => '/opt/rh/httpd24/root/usr/sbin/apachectl -t',
    }
    # Hack to set mode of auth_openidc.conf
    File <| title == 'apache_auth_openidc' |> {
      owner     => 'root',
      group     => 'apache',
      mode      => '0640',
      show_diff => false,
    }
  }

  if $openondemand::auth_type == 'cilogon' {
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
  }

  if $openondemand::auth_type == 'cilogon' and $openondemand::oidc_provider {
    $oidc_provider_filename = regsubst($openondemand::oidc_provider, '/', '%2F', 'G')
    $oidc_provider_config = "/opt/rh/httpd24/root/etc/httpd/metadata/${oidc_provider_filename}.provider"
    $oidc_config_url = "https://${openondemand::oidc_provider}/.well-known/openid-configuration"
    file { "/opt/rh/httpd24/root/etc/httpd/metadata/${oidc_provider_filename}.conf":
      ensure  => 'file',
      content => template('openondemand/apache/oidc-provider.conf.erb'),
      notify  => Class['Apache::Service'],
    }
    file { "/opt/rh/httpd24/root/etc/httpd/metadata/${oidc_provider_filename}.client":
      ensure  => 'file',
      content => template('openondemand/apache/oidc-provider.client.erb'),
      notify  => Class['Apache::Service'],
    }
    exec { 'get oidc configuration':
      path    => '/usr/bin:/bin:/usr/sbin:/sbin',
      command => "curl --fail ${oidc_config_url} | python -m json.tool > ${oidc_provider_config}",
      creates => "/opt/rh/httpd24/root/etc/httpd/metadata/${oidc_provider_filename}.provider",
      require => File['/opt/rh/httpd24/root/etc/httpd/metadata'],
      notify  => Class['Apache::Service'],
    }
    ->file { $oidc_provider_config:
      ensure => 'file',
    }
  }

  shellvar { 'HTTPD24_HTTPD_SCLS_ENABLED':
    ensure  => 'present',
    target  => '/opt/rh/httpd24/service-environment',
    value   => 'httpd24 rh-ruby22',
    require => Package['httpd'],
    notify  => Class['Apache::Service'],
  }

  if $::service_provider == 'systemd' {
    systemd::dropin_file { 'ood.conf':
      unit    => "${::apache::service_name}.service",
      content => join([
        '[Service]',
        'KillSignal=SIGTERM',
        'KillMode=process',
        'PrivateTmp=false',
      ], "\n"),
      notify  => Class['::apache::service'],
    }
    Class['systemd::systemctl::daemon_reload'] -> Class['::apache::service']
  }

  if $openondemand::auth_type == 'basic' {
    $_basic_auth_users_defaults = {
      'ensure'    => 'present',
      'file'      => '/opt/rh/httpd24/root/etc/httpd/.htpasswd',
      'mechanism' => 'basic',
      'require'   => Package['httpd'],
    }
    create_resources('httpauth', $openondemand::basic_auth_users, $_basic_auth_users_defaults)
  }

}
