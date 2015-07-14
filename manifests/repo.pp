# == Define: aptly::repo
#
# Create a repository using `aptly create`. It will not snapshot, or update the
# repository for you, because it will take a long time and it doesn't make sense
# to schedule these actions frequently in Puppet.
#
# === Parameters
#
# [*component*]
#   Specify which component to put the package in. This option will only works
#   for aptly version >= 0.5.0.
#
define aptly::repo(
  $component = '',
){
  validate_string($component)

  include ::aptly

  $aptly_cmd = "${::aptly::aptly_cmd} repo"

  if empty($component) {
    $component_arg = ''
  } else{
    $component_arg = "-component=\"${component}\""
  }


  exec{ "aptly_repo_create-${title}":
    command => "${aptly_cmd} create ${component_arg} ${title}",
    unless  => "${aptly_cmd} show ${title} >/dev/null",
    user    => $::aptly::user,
    require => [
      Package['aptly'],
      File['/etc/aptly.conf'],
    ],
  }
}
