# Private class.
class openondemand::config {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  sudo::conf { 'ood':
    content => template('openondemand/sudo.erb')
  }

}
