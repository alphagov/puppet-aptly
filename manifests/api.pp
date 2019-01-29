# == Class: aptly::api
#
# Install and configure Aptly's API Service
#
# === Parameters
#
# [*ensure*]
#   Ensure to pass on to service type
#   Default: running
#
# [*user*]
#   User to run the service as.
#   Default: root
#
# [*group*]
#   Group to run the service as.
#   Default: root
#
# [*listen*]
#   What IP/port to listen on for API requests.
#   Default: ':8080'
#
# [*log*]
#   Enable or disable Upstart logging.
#   Default: none
#
# [*enable_cli_and_http*]
#   Enable concurrent use of command line (CLI) and HTTP APIs with
#   the same Aptly root.
#
class aptly::api (
  Enum['stopped','running'] $ensure = running,
  $user                             = 'root',
  $group                            = 'root',
  $listen                           = ':8080',
  Enum['none','log'] $log           = 'none',
  Boolean $enable_cli_and_http      = false,
  ) {
  validate_string($user, $group)
  validate_re($listen, ['^([0-9.]*:[0-9]+$|unix:)'], 'Valid values for $listen: :port, <ip>:<port>, unix:///path')

  if $::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '15.04') < 0 {
    file { 'aptly-upstart':
      path    => '/etc/init/aptly-api.conf',
      content => template('aptly/etc/aptly-api.init.erb'),
      notify  => Service['aptly-api'],
    }
  } else {
    file { 'aptly-systemd':
      path    => '/etc/systemd/system/aptly-api.service',
      content => template('aptly/etc/aptly-api.systemd.erb'),
    }
    ~> exec { 'aptly-api-systemd-reload':
      command     => 'systemctl daemon-reload',
      path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
      refreshonly => true,
      notify      => Service['aptly-api'],
    }
  }

  service { 'aptly-api':
    ensure => $ensure,
    enable => true,
  }
}
