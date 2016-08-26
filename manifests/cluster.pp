#
define openondemand::cluster (
  $cluster_title = $name,
  $url = "http://${::domain}",
  $group_validators = {},
  $login_server = undef,
  $resource_mgr_type = 'torque',
  $resource_mgr_host = undef,
  $resource_mgr_lib = undef,
  $resource_mgr_bin = undef,
  $resource_mgr_version = undef,
  $scheduler_type = 'moab',
  $scheduler_host = undef,
  $scheduler_bin = undef,
  $scheduler_version = undef,
  $scheduler_params = {},
  $ganglia_host = undef,
  $ganglia_scheme = 'https://',
  $ganglia_segments = ['gweb', 'graph.php'],
  $ganglia_req_query = {'c' => $name},
  $ganglia_opt_query = {'h' => "%{h}.${::domain}"},
  $ganglia_version = '3',
) {

  case $resource_mgr_type {
    'torque': {
      $_resource_mgr_type = 'OodCluster::Servers::Torque'
    }
    default: {
      fail("openondemand::cluster: unsupported resource manager type '${resource_mgr_type}', only torque is supported")
    }
  }

  case $scheduler_type {
    'moab': {
      $_scheduler_type = 'OodCluster::Servers::Moab'
    }
    default: {
      fail("openondemand::cluster: unsupported scheduler type '${scheduler_type}', only moab is supported")
    }
  }

  file { "/etc/ood/config/clusters.d/${name}.yml":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('openondemand/cluster/main.yml.erb'),
  }

}
