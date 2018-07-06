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

# [*config_contents*]
#   Contents of the config file.
#   Default: undef
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
  $package_ensure  = present,
  $config_file     = '/etc/aptly.conf',
  $config          = {},
  $config_contents = undef,
  $repo            = true,
  $key_server      = undef,
  $user            = 'root',
  $aptly_repos     = {},
  $aptly_mirrors   = {},
) {

  validate_absolute_path($config_file)
  validate_hash($config)
  validate_hash($aptly_repos)
  validate_hash($aptly_mirrors)
  validate_bool($repo)
  validate_string($key_server)
  validate_string($user)

  if $config_contents {
    validate_string($config_contents)
  }

  if $repo {
    apt::source { 'aptly':
      location   => 'http://repo.aptly.info',
      release    => 'squeeze',
      repos      => 'main',
      key        =>  {
        key_server => $key_server,
        id        => 'DF32BC15E2145B3FA151AED19E3E53F19C7DE460',
      }
    }

    Apt::Source['aptly'] -> Class['apt::update'] -> Package['aptly']
  }

  package { 'aptly':
    ensure  => $package_ensure,
  }

  $config_file_contents = $config_contents ? {
    undef   => inline_template("<%= Hash[@config.sort].to_pson %>\n"),
    default => $config_contents,
  }

  file { $config_file:
    ensure  => file,
    content => $config_file_contents,
  }

  $aptly_cmd = "/usr/bin/aptly -config ${config_file}"

  # Hiera support
  create_resources('::aptly::repo', $aptly_repos)
  create_resources('::aptly::mirror', $aptly_mirrors)
}
