# See README.md for more details.
class openondemand (
  Array $package_dependencies                     = $openondemand::params::package_dependencies,
  Array $scl_packages                             = $openondemand::params::scl_packages,
  String $packages_ensure                         = 'present',
  Optional[String] $ood_portal_generator_ensure   = undef,
  String $ood_portal_generator_revision           = 'master',
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

  Openondemand::Nginx_stage_namespace_config $nginx_stage_app_root  = $openondemand::params::nginx_stage_app_root,
  String $nginx_stage_scl_env = 'nginx16 rh-passenger40 rh-ruby22 nodejs010 git19',
  Optional[Openondemand::Nginx_stage_namespace_config] $nginx_stage_app_request_regex = undef,

  Hash $clusters = {},
  Boolean $clusters_hiera_hash = true,

  # Used by openondemand::app::installer
  Optional[String] $default_sshhost = undef,
  Optional[String] $bc_desktop_ood_site = undef,
  Boolean $install_bc_desktop = false,
  Optional[Hash] $dashboard_config = undef,

  Optional[String] $develop_root_dir = undef,
  Variant[Array, Hash] $usr_apps  = {},
  Hash $usr_app_defaults = {},

  Boolean $manage_apps_config = true,
  Optional[String] $apps_config_repo = undef,
  Optional[String] $apps_config_revision = undef,
  String $apps_config_repo_path = '',
  Optional[String] $apps_config_source = undef,
  Optional[Stdlib::Absolutepath] $apps_config_target = undef,
) inherits openondemand::params {

  $_web_directory = dirname($public_root)

  $_ood_portal_generator_ensure   = pick($ood_portal_generator_ensure, $packages_ensure)
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
    $_clusters = lookup('openondemand::clusters', Hash, 'deep', {})
  } else {
    $_clusters = $clusters
  }

  if $default_sshhost {
    $default_sshhost_env = "DEFAULT_SSHHOST=${default_sshhost}"
  } else {
    $default_sshhost_env = undef
  }

  if $bc_desktop_ood_site {
    $bc_desktop_ood_site_env = "OOD_SITE=${bc_desktop_ood_site}"
  } else {
    $bc_desktop_ood_site_env = undef
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

  $ood_portal_config = delete_undef_values({
    'listen_addr_port'    => $listen_ports,
    'servername'          => $servername,
    'port'                => $port,
    'ssl'                 => $ssl,
    'logroot'             => $logroot,
    'lua_root'            => $lua_root,
    'lua_log_level'       => $lua_log_level,
    'user_map_cmd'        => $user_map_cmd,
    'user_env'            => $user_env,
    'map_fail_uri'        => $map_fail_uri,
    'pun_stage_cmd'       => $pun_stage_cmd,
    'auth'                => $auth,
    'root_uri'            => $root_uri,
    'analytics'           => $analytics,
    'public_uri'          => $public_uri,
    'public_root'         => $public_root,
    'logout_uri'          => $logout_uri,
    'logout_redirect'     => $logout_redirect,
    'host_regex'          => $host_regex,
    'node_uri'            => $node_uri,
    'rnode_uri'           => $rnode_uri,
    'nginx_uri'           => $nginx_uri,
    'pun_uri'             => $pun_uri,
    'pun_socket_root'     => $pun_socket_root,
    'pun_max_retries'     => $pun_max_retries,
    'oidc_uri'            => $oidc_uri,
    'oidc_discover_uri'   => $oidc_discover_uri,
    'oidc_discover_root'  => $oidc_discover_root,
    'register_uri'        => $register_uri,
    'register_root'       => $register_root,
  })

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

}
