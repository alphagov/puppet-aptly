# == Define: aptly::repo
#
# Create a repository using `aptly create`. It will not snapshot, or update the
# repository for you, because it will take a long time and it doesn't make sense
# to schedule these actions frequently in Puppet.
#
# === Parameters
#
# [*architectures*]
#   Specify the list of supported architectures as an Array. If ommited Aptly
#   assumes the repository.
#
# [*comment*]
#   Specifiy a comment to be set for the repository.
#
# [*component*]
#   Specify which component to put the package in. This option will only works
#   for aptly version >= 0.5.0.
#
# [*distribution*]
#   Specify the default distribution to be used when publishing this repository.

define aptly::repo(
  Array $architectures = [],
  String $comment       = '',
  String $component     = '',
  String $distribution  = '',
){
  include ::aptly

  $aptly_cmd = "${::aptly::aptly_cmd} repo"

  if empty($architectures) {
    $architectures_arg = ''
  } else{
    $architectures_as_s = join($architectures, ',')
    $architectures_arg = "-architectures=\"${architectures_as_s}\""
  }

  if empty($comment) {
    $comment_arg = ''
  } else{
    $comment_arg = "-comment=\"${comment}\""
  }

  if empty($component) {
    $component_arg = ''
  } else{
    $component_arg = "-component=\"${component}\""
  }

  if empty($distribution) {
    $distribution_arg = ''
  } else{
    $distribution_arg = "-distribution=\"${distribution}\""
  }

  exec{ "aptly_repo_create-${title}":
    command => "${aptly_cmd} create ${architectures_arg} ${comment_arg} ${component_arg} ${distribution_arg} ${title}",
    unless  => "${aptly_cmd} show ${title} >/dev/null",
    user    => $::aptly::user,
    require => [
      Package['aptly'],
      File['/etc/aptly.conf'],
    ],
  }
}
