# == Define: aptly::repo
#
# Create a repository using `aptly create`. It will not snapshot, or update the
# repository for you, because it will take a long time and it doesn't make sense
# to schedule these actions frequently in Puppet. 
#
# === Parameters
#
# [*component*]
#   Specify which component to put the package in. Default to 'main'
#
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
