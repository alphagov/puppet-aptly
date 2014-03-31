# == Define: aptly::mirror
#
# Create a mirror using `aptly mirror create`. It will not update, snapshot,
# or publish the mirror for you, because it will take a long time and it
# doesn't make sense to schedule these actions frequenly in Puppet.
#
# The parameters are intended to be analogous to `apt::source`.
#
# NB: This will not recreate the mirror if the params change! You will need
# to manually `aptly mirror drop <name>` after also dropping all snapshot
# and publish references.
#
# === Parameters
#
# [*location*]
#   URL of the APT repo.
#
# [*key*]
#   Import the GPG key into the `trustedkeys` keyring so that aptly can
#   verify the mirror's manifests.
#
# [*release*]
#   Distribution to mirror for.
#   Default: `$::lsbdistcodename`
#
# [*repos*]
#   Components to mirror. If an empty array then aptly will default to
#   mirroring all components.
#   Default: []
#
define aptly::mirror (
  $location,
  $key,
  $release = $::lsbdistcodename,
  $repos = [],
) {
  validate_array($repos)

  $gpg_cmd = '/usr/bin/gpg --no-default-keyring --keyring trustedkeys.gpg'
  $aptly_cmd = '/usr/bin/aptly mirror'
  $exec_key_title = "aptly_mirror_key-${key}"

  if empty($repos) {
    $components_arg = ''
  } else {
    $components = join($repos, ' ')
    $components_arg = " ${components}"
  }

  if !defined(Exec[$exec_key_title]) {
    exec { $exec_key_title:
      command => "${gpg_cmd} --keyserver 'keyserver.ubuntu.com' --recv-keys '${key}'",
      unless  => "${gpg_cmd} --list-keys '${key}'",
      user    => 'root',
    }
  }

  exec { "aptly_mirror_create-${title}":
    command => "${aptly_cmd} create ${title} ${location} ${release}${components_arg}",
    unless  => "${aptly_cmd} show ${title} >/dev/null",
    user    => 'root',
    require => [
      Class['aptly'],
      Exec[$exec_key_title],
    ],
  }
}
