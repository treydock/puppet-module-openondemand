# Private class.
class openondemand::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  ensure_packages($openondemand::scl_packages)

}
