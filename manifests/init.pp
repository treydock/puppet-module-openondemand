# See README.md for more details.
class openondemand (
  $scl_packages         = $openondemand::params::scl_packages,

  # Apache
  $declare_apache       = true,

  $ssl_certificate_file     = '/etc/pki/tls/certs/localhost.crt',
  $ssl_certificate_key_file = '/etc/pki/tls/private/localhost.key',

  $cilogon_client_id      = '',
  $cilogon_client_secret  = '',

  #
  $ood_ssl                          = true,
  $ood_ssl_redirect                 = true,
  $ood_ip                           = $::ipaddress,
  $ood_port                         = '443',
  $ood_server_name                  = $::fqdn,
  $ood_public_root                  = '/var/www/ood/public',
  $ood_public_uri                   = '/public',
  $ood_user_map_cmd                 = '/opt/ood/ood_auth_map/bin/ood_auth_map',
  $ood_pun_stage_cmd                = 'sudo /opt/ood/nginx_stage/sbin/nginx_stage',
  $ood_map_fail_uri                 = '/register',
  $ood_lua_root                     = '/opt/ood/mod_ood_proxy/lib',
  $ood_node_uri                     = '/node',
  $ood_rnode_uri                    = '/rnode',
  $ood_auth_type                    = 'openid-connect',
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

  # nginx
  $declare_nginx        = true,

  $package_ensure       = 'present',
  $package_name         = $openondemand::params::package_name,
  $service_name         = $openondemand::params::service_name,
  $service_ensure       = 'running',
  $service_enable       = true,
  $service_hasstatus    = $openondemand::params::service_hasstatus,
  $service_hasrestart   = $openondemand::params::service_hasrestart,
  $config_path          = $openondemand::params::config_path
) inherits openondemand::params {

  include openondemand::install
  include openondemand::apache
  #include openondemand::nginx
  include openondemand::config
  include openondemand::service

  anchor { 'openondemand::start': }->
  Class['openondemand::install']->
  Class['openondemand::apache']->
  #Class['openondemand::nginx']->
  Class['openondemand::config']~>
  Class['openondemand::service']->
  anchor { 'openondemand::end': }

}
