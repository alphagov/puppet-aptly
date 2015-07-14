# == Define: aptly::snapshot
#
# Create a snapshot using `aptly snapshot`.
#
# === Parameters
#
# [*repo*]
#   Create snapshot from given repo.
#
# [*mirror*]
#   Create snapshot from given mirror.
#
define aptly::snapshot (
  $repo   = undef,
  $mirror = undef,
) {

  include aptly

  $aptly_cmd = "${::aptly::aptly_cmd} snapshot"

  if $repo and $mirror {
    fail('$repo and $mirror are mutually exclusive.')
  }
  elsif $repo {
    $aptly_args = "create ${title} from repo ${repo}"
  }
  elsif $mirror {
    $aptly_args = "create ${title} from mirror ${mirror}"
  }
  else {
    $aptly_args = "create ${title} empty"
  }

  exec { "aptly_snapshot_create-${title}":
    command => "${aptly_cmd} ${aptly_args}",
    unless  => "${aptly_cmd} show ${title} >/dev/null",
    user    => $::aptly::user,
    require => Class['aptly'],
  }

}
