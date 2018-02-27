#
class openondemand::repo {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $baseurl = "${openondemand::repo_baseurl_prefix}/${openondemand::repo_release}/web/el${facts['os']['release']['major']}/\$basearch"

  yumrepo { 'ondemand-web':
    descr           => 'Open OnDemand Web Repo',
    baseurl         => $baseurl,
    enabled         => '1',
    gpgcheck        => '1',
    gpgkey          => $openondemand::repo_gpgkey,
    metadata_expire => '1'
  }

}
