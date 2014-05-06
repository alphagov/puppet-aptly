# == Define: aptly::repo
#
# === Parameters
#
# [*component*]
#   Name of the component.
define aptly::repo(
  $component = 'main'
){
  $aptly_cmd = '/usr/bin/aptly repo'

  exec{ "aptly_repo_create-${title}":
    command => "${aptly_cmd} create ${title} -component=\"${component}\"",
    unless  => "${aptly_cmd} show ${title} >/dev/null",
    user    => 'root',
    require => [
      Class['aptly'],
    ],
  }
}
