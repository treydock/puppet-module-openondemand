# See README.md for more details.
class openondemand (
  Array $package_dependencies                     = $openondemand::params::package_dependencies,
  Array $scl_packages                             = $openondemand::params::scl_packages,
  String $packages_ensure                         = 'present',
  Optional[String] $mod_ood_proxy_ensure          = undef,
  String $mod_ood_proxy_revision                  = 'master',
  Optional[String] $nginx_stage_ensure            = undef,
  String $nginx_stage_revision                    = 'master',
  Optional[String] $ood_auth_map_ensure           = undef,
  String $ood_auth_map_revision                   = 'master',
  Optional[String] $ood_auth_discovery_ensure     = undef,
  String $ood_auth_discovery_revision             = 'master',
  Optional[String] $ood_auth_registration_ensure  = undef,
  String $ood_auth_registration_revision          = 'master',
  Boolean $manage_app_installer                   = true,
  Optional[String] $app_installer_ensure          = undef,
  String $app_installer_revision                  = 'master',

  # Apache
  Boolean $declare_apache = true,

  String $cilogon_client_id      = '',
  String $cilogon_client_secret  = '',
  String $oidc_crypto_passphrase  = 'CHANGEME',

  #
  Variant[Array, String, Undef] $listen_addr_port = undef,
  Optional[String] $servername = undef,
  Optional[Array] $ssl = undef,
  String  $logroot = 'logs',
  String $lua_root = '/opt/ood/mod_ood_proxy/lib',
  Optional[String] $lua_log_level = undef,
  String $user_map_cmd  = '/opt/ood/ood_auth_map/bin/ood_auth_map.regex',
  Optional[String] $user_env = undef,
  Optional[String] $map_fail_uri = undef,
  Enum['cilogon', 'openid-connect', 'shibboleth', 'ldap', 'basic'] $auth_type = 'basic',
  Optional[Array] $auth_configs = $openondemand::params::auth_configs,

  String $root_uri = '/pun/sys/dashboard',

  Optional[Struct[{url => String, id => String}]] $analytics = undef,

  String $public_uri = '/public',
  String $public_root = '/var/www/ood/public',

  String $logout_uri = '/logout',
  String $logout_redirect = '/pun/sys/dashboard/logout',

  String $host_regex = '[^/]+',
  Optional[String] $node_uri = undef,
  Optional[String] $rnode_uri = undef,

  String $nginx_uri = '/nginx',
  String $pun_uri = '/pun',
  String $pun_socket_root = '/var/run/nginx',
  Integer $pun_max_retries = 5,

  Optional[String] $oidc_uri = undef,
  Optional[String] $oidc_discover_uri = undef,
  Optional[String] $oidc_discover_root = undef,
  Optional[String] $oidc_provider = undef,
  Optional[String] $oidc_provider_token_endpoint_auth = undef,
  String $oidc_provider_scope = 'openid email',
  String $oidc_provider_client_id = '',
  String $oidc_provider_client_secret = '',
  Optional[String] $oidc_remote_user_claim = undef,

  Optional[String] $register_uri = undef,
  Optional[String] $register_root = undef,

  Hash $basic_auth_users  = $openondemand::params::basic_auth_users,

  Hash $nginx_stage_app_root  = $openondemand::params::nginx_stage_app_root,
  String $nginx_stage_ood_ruby_scl  = 'nginx16 rh-passenger40 rh-ruby22 nodejs010 git19',

  Hash $clusters = {},
  Boolean $clusters_hiera_hash = true,
  Optional[String] $default_sshhost = undef,

  Optional[String] $develop_root_dir = undef,
  Variant[Array, Hash] $usr_apps  = {},
  Hash $usr_app_defaults = {},
) inherits openondemand::params {

  $_web_directory = dirname($public_root)

  $_mod_ood_proxy_ensure          = pick($mod_ood_proxy_ensure, $packages_ensure)
  $_nginx_stage_ensure            = pick($nginx_stage_ensure, $packages_ensure)
  $_ood_auth_map_ensure           = pick($ood_auth_map_ensure, $packages_ensure)
  $_ood_auth_discovery_ensure     = pick($ood_auth_discovery_ensure, $packages_ensure)
  $_ood_auth_registration_ensure  = pick($ood_auth_registration_ensure, $packages_ensure)
  $_app_installer_ensure          = pick($app_installer_ensure, $packages_ensure)

  if $ssl {
    $port = '443'
    $listen_ports = ['443', '80']
  } else {
    $port = '80'
    $listen_ports = ['80']
  }

  $nginx_stage_cmd = '/opt/ood/nginx_stage/sbin/nginx_stage'
  $pun_stage_cmd = "sudo ${nginx_stage_cmd}"

  case $auth_type {
    'ldap': {
      $auth = ['AuthType basic'] + $auth_configs
    }
    'cilogon': {
      $auth = ['AuthType openid-connect'] + $auth_configs
    }
    # Applies to basic, shibboleth, and openid-connect
    default: {
      $auth = ["AuthType ${auth_type}"] + $auth_configs
    }
  }

  if $clusters_hiera_hash {
    $_clusters = hiera_hash('openondemand::clusters', {})
  } else {
    $_clusters = $clusters
  }

  if $default_sshhost {
    $default_sshhost_env = "DEFAULT_SSHHOST=${default_sshhost}"
  } else {
    $default_sshhost_env = undef
  }

  if $develop_root_dir {
    $_develop_mode = true
    $_sys_ensure = 'link'
    $_sys_target = "${develop_root_dir}/sys"
    $_public_ensure = 'link'
    $_public_target = "${develop_root_dir}/public"
    $_discover_target = "${develop_root_dir}/discover"
    $_register_target = "${develop_root_dir}/register"
  } else {
    $_develop_mode = false
    $_sys_ensure = 'directory'
    $_sys_target = undef
    $_public_ensure = 'directory'
    $_public_target = undef
    $_discover_target = undef
    $_register_target = undef
  }

  include openondemand::install
  include openondemand::apps
  include openondemand::apache
  include openondemand::config
  include openondemand::service

  anchor { 'openondemand::start': }
  ->Class['openondemand::install']
  ->Class['openondemand::apps']
  ->Class['openondemand::apache']
  ->Class['openondemand::config']
  ->Class['openondemand::service']
  ->anchor { 'openondemand::end': }

  create_resources('openondemand::cluster', $_clusters)

  if is_array($usr_apps) {
    ensure_resource('openondemand::app::usr', $usr_apps, $usr_app_defaults)
  } elsif is_hash($usr_apps) {
    create_resources('openondemand::app::usr', $usr_apps, $usr_app_defaults)
  } else {
    fail("${module_name}: usr_apps must be an array or hash.")
  }

  # Allow templates to get scope of openondemand class
  @::apache::custom_config { 'ood-portal':
    content        => template('openondemand/apache/ood-portal.conf.erb'),
    priority       => '10',
    verify_command => '/opt/rh/httpd24/root/usr/sbin/apachectl -t',
  }

}
