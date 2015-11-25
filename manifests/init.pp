# == Class: aptly
#
# aptly is a swiss army knife for Debian repository management
#
# === Parameters
#
# [*package_ensure*]
#   Ensure parameter to pass to the package resource.
#   Default: present
#
# [*config_file*]
#   Absolute path to the configuration file. Defaults to
#   `/etc/aptly.conf`.
#
# [*config*]
#   Hash of configuration options for `/etc/aptly.conf`.
#   See http://www.aptly.info/#configuration
#   Default: {}
#
# [*repo*]
#   Whether to configure an apt::source for `repo.aptly.info`.
#   You might want to disable this if/when you've mirrored that yourself.
#   Default: true
#
# [*key_server*]
#   Key server to use when `$repo` is true. Uses the default of
#   `apt::source` if not specified.
#   Default: undef
#
# [*user*]
#   The user to use when performing an aptly command
#   Default: 'root'
#
# [*aptly_repos*]
#   Hash of aptly repos which is passed to aptly::repo
#   Default: {}
#
# [*aptly_mirrors*]
#   Hash of aptly mirrors which is passed to aptly::mirror
#   Default: {}
#
class aptly (
  $package_ensure = present,
  $config_file    = '/etc/aptly.conf',
  $config         = {},
  $repo           = true,
  $key_server     = undef,
  $user           = 'root',
  $aptly_repos    = {},
  $aptly_mirrors  = {},
) {

  validate_absolute_path($config_file)
  validate_hash($config)
  validate_hash($aptly_repos)
  validate_hash($aptly_mirrors)
  validate_bool($repo)
  validate_string($key_server)
  validate_string($user)

  if $repo {
    apt::source { 'aptly':
      location   => 'http://repo.aptly.info',
      release    => 'squeeze',
      repos      => 'main',
      key_server => $key_server,
      key        => 'B6140515643C2AE155596690E083A3782A194991',
    }

    Apt::Source['aptly'] -> Package['aptly']
  }

  package { 'aptly':
    ensure  => $package_ensure,
  }

  file { $config_file:
    ensure  => file,
    content => inline_template("<%= Hash[@config.sort].to_pson %>\n"),
  }

  $aptly_cmd = "/usr/bin/aptly -config ${config_file}"

  # Hiera support
  create_resources('::aptly::repo', $aptly_repos)
  create_resources('::aptly::mirror', $aptly_mirrors)
}
