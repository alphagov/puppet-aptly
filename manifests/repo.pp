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
# [*config_file*]
#   Specify the config file for the repository.
#
# [*distribution*]
#   Specify the default distribution to be used when publishing this repository.

define aptly::repo(
  $architectures = [],
  $comment       = '',
  $component     = '',
  $config_file   = '',
  $distribution  = '',
){
  validate_array($architectures)
  validate_string($comment)
  validate_string($component)
  validate_string($distribution)

  include ::aptly


  if empty($architectures) {
    $architectures_arg = ''
  } else{
    $architectures_as_s = join($architectures, ',')
    $architectures_arg = "-architectures=\"${architectures_as_s}\""
  }

  if empty($config_file) {
    $config_arg = "-config ${::aptly::config_file}"
    $config     = $::aptly::config_file
    $aptly_cmd  = "${::aptly::aptly_cmd} repo"
  } else {
    $config_arg = "-config ${config_file}"
    $config     = $config_file
    $aptly_cmd  = "/usr/bin/aptly ${config_arg} repo"
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
      File[$config],
    ],
  }
}
