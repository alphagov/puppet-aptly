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
# [*architectures*]
#   Architectures to mirror. If an empty array then aptly will default to
#   mirroring all architectures.
#   Default: []
define aptly::repo(
  $component = '',
  $architectures = []
){
  validate_string($component)

  include aptly

  $aptly_cmd = '/usr/bin/aptly repo'

  if empty($component) {
    $component_arg = ''
  } else{
    $component_arg = "-component=\"${component}\""
  }

  if empty($architectures) {
    $arch_arg = ''
  } else {
    $archs_concat = join($architectures, ',')
    $arch_arg = " -architectures=\"${archs_concat}\""
  }

  exec{ "aptly_repo_create-${title}":
    command => "${aptly_cmd}${arch_arg} create ${component_arg} ${title}",
    unless  => "${aptly_cmd} show ${title} >/dev/null",
    user    => $::aptly::user,
    require => [
      Class['aptly'],
    ],
  }
}
