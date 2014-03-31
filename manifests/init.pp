# == Class: aptly
#
# aptly is a swiss army knife for Debian repository management
#
class aptly {
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
}
