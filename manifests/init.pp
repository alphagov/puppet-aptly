# == Class: aptly
#
# aptly is a swiss army knife for Debian repository management
#
# === Parameters
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
class aptly (
  $config = {},
  $repo = true,
) {

  validate_hash($config)
  validate_bool($repo)

  if $repo {
    apt::source { 'aptly':
      location    => 'http://repo.aptly.info',
      release     => 'squeeze',
      repos       => 'main',
      key         => '2A194991',
      include_src => false,
    }

    Apt::Source['aptly'] -> Package['aptly']
  }

  package { 'aptly':
    ensure  => present,
  }

  file { '/etc/aptly.conf':
    ensure  => file,
    content => inline_template("<%= Hash[@config.sort].to_pson %>\n"),
  }
}
