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
class aptly (
  $config = {},
) {

  validate_hash($config)

  apt::source { 'aptly':
    location    => 'http://repo.aptly.info',
    release     => 'squeeze',
    repos       => 'main',
    key         => '2A194991',
    include_src => false,
  }

  package { 'aptly':
    ensure  => present,
    require => Apt::Source['aptly'],
  }

  file { '/etc/aptly.conf':
    ensure  => file,
    content => inline_template("<%= @config.to_pson %>\n"),
  }
}
