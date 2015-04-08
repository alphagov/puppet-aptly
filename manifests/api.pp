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
# [*listen*]
#   What IP/port to listen on for API requests.
#   Default: ':8080'
#
# [*log*]
#   Enable or disable Upstart logging.
#   Default: none

class aptly::api (
  $ensure         = running,
  $listen         = ':8080',
  $log            = 'none',
  ) {
    
    validate_re($ensure, ['^stopped|running$'], 'Valid values for $ensure: stopped, running')
    
    validate_re($listen, ['^[0-9.]*:[0-9]+$'], 'Valid values for $listen: :port, <ip>:<port>')
    
    validate_re($log, ['^none|log$'], 'Valid values for $log: none, log')
    
    file{'aptly-upstart':
      path    => '/etc/init/aptly-api.conf',
      content => template('aptly/etc/aptly.init.erb'),
    }
    
    service{'aptly-api':
      ensure => $ensure,
      enable => true,
    }
    
    File['aptly-upstart'] ~> Service['aptly-api']
  
}
