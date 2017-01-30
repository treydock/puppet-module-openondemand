# See README.md for more details.
class openondemand (
  $scl_packages                   = $openondemand::params::scl_packages,
  $packages_ensure                = 'present',
  $mod_ood_proxy_ensure           = undef,
  $mod_ood_proxy_revision         = 'master',
  $nginx_stage_ensure             = undef,
  $nginx_stage_revision           = 'master',
  $ood_auth_map_ensure            = undef,
  $ood_auth_map_revision          = 'master',
  $ood_auth_discovery_ensure      = undef,
  $ood_auth_discovery_revision    = 'master',
  $ood_auth_registration_ensure   = undef,
  $ood_auth_registration_revision = 'master',

  # Apache
  $declare_apache       = true,

  $ssl_certificate_file     = '/etc/pki/tls/certs/localhost.crt',
  $ssl_certificate_key_file = '/etc/pki/tls/private/localhost.key',
  $ssl_certificate_chain_file = undef,

  $cilogon_client_id      = '',
  $cilogon_client_secret  = '',

  #
  $ood_ssl                          = true,
  $ood_ssl_redirect                 = true,
  $ood_ip                           = $::ipaddress,
  $ood_port                         = '443',
  $ood_server_name                  = $::fqdn,
  $ood_server_aliases               = [],
  $ood_logs                         = true,
  $ood_public_root                  = '/var/www/ood/public',
  $ood_host_regex                   = '[^/]+',
  $ood_public_uri                   = '/public',
  $ood_user_map_cmd                 = '/opt/ood/ood_auth_map/bin/ood_auth_map',
  $ood_pun_stage_cmd                = '/opt/ood/nginx_stage/sbin/nginx_stage',
  $ood_pun_stage_cmd_sudo           = true,
  $ood_map_fail_uri                 = '/register',
  $ood_lua_root                     = '/opt/ood/mod_ood_proxy/lib',
  $ood_lua_log_level                = 'info',
  $ood_node_uri                     = '/node',
  $ood_rnode_uri                    = '/rnode',
  $ood_auth_type                    = 'openid-connect',
  $ood_auth_extend                  = [],
  $ood_pun_uri                      = '/pun',
  $ood_pun_socket_root              = '/var/run/nginx',
  $ood_pun_max_retries              = '5',
  $ood_nginx_uri                    = '/nginx',
  $ood_root_uri                     = '/pun/sys/dashboard',
  $ood_auth_setup                   = true,
  $ood_auth_oidc_uri                = '/oidc',
  $ood_auth_oidc_crypto_passphrase  = 'CHANGEME',
  $ood_auth_discover_uri            = '/discover',
  $ood_auth_discover_root           = '/var/www/ood/discover',
  $ood_auth_register_uri            = '/register',
  $ood_auth_register_root           = '/var/www/ood/register',

  $ood_analytics_opt_in             = false,
  $ood_analytics_tracking_url       = 'http://www.google-analytics.com/collect',
  $ood_analytics_tracking_id        = 'UA-79331310-4',

  $nginx_stage_app_root             = $openondemand::params::nginx_stage_app_root,
  $nginx_stage_ood_ruby_scl         = 'nginx16 rh-passenger40 rh-ruby22 nodejs010 git19',

  $clusters = {},
  $clusters_hiera_hash = true,

  $develop_root_dir = undef,
  $usr_apps         = {},
  $usr_app_defaults = {},
) inherits openondemand::params {

  validate_array($ood_server_aliases)

  if $ood_pun_stage_cmd_sudo {
    $_ood_pun_stage_cmd_full = "sudo ${ood_pun_stage_cmd}"
  } else {
    $_ood_pun_stage_cmd_full = $ood_pun_stage_cmd
  }

  $_ood_web_directory = dirname($ood_public_root)

  $_mod_ood_proxy_ensure          = pick($mod_ood_proxy_ensure, $packages_ensure)
  $_nginx_stage_ensure            = pick($nginx_stage_ensure, $packages_ensure)
  $_ood_auth_map_ensure           = pick($ood_auth_map_ensure, $packages_ensure)
  $_ood_auth_discovery_ensure     = pick($ood_auth_discovery_ensure, $packages_ensure)
  $_ood_auth_registration_ensure  = pick($ood_auth_registration_ensure, $packages_ensure)

  if $clusters_hiera_hash {
    $_clusters = hiera_hash('openondemand::clusters', {})
  } else {
    $_clusters = $clusters
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
  include openondemand::apache
  include openondemand::config
  include openondemand::service

  anchor { 'openondemand::start': }->
  Class['openondemand::install']->
  Class['openondemand::apache']->
  Class['openondemand::config']->
  Class['openondemand::service']->
  anchor { 'openondemand::end': }

  create_resources('openondemand::cluster', $_clusters)

  if is_array($usr_apps) {
    ensure_resource('openondemand::app::usr', $usr_apps, $usr_app_defaults)
  } elsif is_hash($usr_apps) {
    create_resources('openondemand::app::usr', $usr_apps, $usr_app_defaults)
  } else {
    fail("${module_name}: usr_apps must be an array or hash.")
  }

}
