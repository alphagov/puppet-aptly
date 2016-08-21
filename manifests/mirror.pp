# == Define: aptly::mirror
#
# Create a mirror using `aptly mirror create`. It will not update, snapshot,
# or publish the mirror for you, because it will take a long time and it
# doesn't make sense to schedule these actions frequenly in Puppet.
#
# NB: This will not recreate the mirror if the params change! You will need
# to manually `aptly mirror drop <name>` after also dropping all snapshot
# and publish references.
#
# === Parameters
#
# [*location*]
#   URL of the APT repo.
#
# [*key*]
#   Import the GPG key into the `trustedkeys` keyring so that aptly can
#   verify the mirror's manifests. May be specified as string or array for
#   multiple keys. If not specified, no action will be taken.
#
# [*keyserver*]
#   The keyserver to use when download the key
#   Default: 'keyserver.ubuntu.com'
#
# [*filter*]
#   Package query that is applied to packages in the mirror
#
# [*release*]
#   Distribution to mirror for.
#   Default: `$::lsbdistcodename`
#
# [*repos*]
#   Components to mirror. If an empty array then aptly will default to
#   mirroring all components.
#   Default: []
#
# [*architectures*]
#   Architectures to mirror. If attribute is ommited Aptly will mirror all
#   available architectures.
#   Default: []
#
# [*with_sources*]
#   Boolean to control whether Aptly should download source packages in addition
#   to binary packages.
#   Default: false
#
# [*with_udebs*]
#   Boolean to control whether Aptly should also download .udeb packages.
#   Default: false
#
# [*filter_with_deps*]
#   Boolean to control whether when filtering to include dependencies of matching 
#   packages as well
#   Default: false
#
# [*environment*]
#   Optional environment variables to pass to the exec.
#   Example: ['http_proxy=http://127.0.0.2:3128']
#   Default: []
define aptly::mirror (
  $location,
  $key              = undef,
  $keyserver        = 'keyserver.ubuntu.com',
  $filter           = '',
  $release          = $::lsbdistcodename,
  $architectures    = [],
  $repos            = [],
  $with_sources     = false,
  $with_udebs       = false,
  $filter_with_deps = false,
  $environment      = [],
) {
  validate_string($keyserver)
  validate_string($filter)
  validate_array($repos)
  validate_array($architectures)
  validate_bool($filter_with_deps)
  validate_bool($with_sources)
  validate_bool($with_udebs)
  validate_array($environment)

  include ::aptly

  $gpg_cmd = '/usr/bin/gpg --no-default-keyring --keyring trustedkeys.gpg'
  $aptly_cmd = "${::aptly::aptly_cmd} mirror"

  if empty($architectures) {
    $architectures_arg = ''
  } else{
    $architectures_as_s = join($architectures, ',')
    $architectures_arg = "-architectures=\"${architectures_as_s}\""
  }

  if empty($repos) {
    $components_arg = ''
  } else {
    $components = join($repos, ' ')
    $components_arg = " ${components}"
  }

  if empty($filter) {
    $filter_arg = ''
  } else{
    $filter_arg = "-filter=\"${filter}\""
  }

  if ($filter_with_deps == true) {
    $filter_with_deps_arg = '-filter-with-deps'
  } else{
    $filter_with_deps_arg = ''
  }

  if $key {
    if is_array($key) {
      $key_string = join($key, "' '")
    } elsif is_string($key) or is_integer($key) {
      $key_string = $key
    } else {
      fail('$key is neither a string nor an array!')
    }

    exec { "aptly_mirror_gpg-${title}":
      path    => '/bin:/usr/bin',
      command => "${gpg_cmd} --keyserver '${keyserver}' --recv-keys '${key_string}'",
      unless  => "echo '${key_string}' | xargs -n1 ${gpg_cmd} --list-keys",
      user    => $::aptly::user,
    }

    $exec_aptly_mirror_create_require = [
      Package['aptly'],
      File['/etc/aptly.conf'],
      Exec["aptly_mirror_gpg-${title}"],
    ]
  } else {
    $exec_aptly_mirror_create_require = [
      Package['aptly'],
      File['/etc/aptly.conf'],
    ]
  }

  exec { "aptly_mirror_create-${title}":
    command     => "${aptly_cmd} create ${architectures_arg} -with-sources=${with_sources} -with-udebs=${with_udebs} ${filter_arg} ${filter_with_deps_arg} ${title} ${location} ${release}${components_arg}",
    unless      => "${aptly_cmd} show ${title} >/dev/null",
    user        => $::aptly::user,
    require     => $exec_aptly_mirror_create_require,
    environment => $environment,
  }
}
