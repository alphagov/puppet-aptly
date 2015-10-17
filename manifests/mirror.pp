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
#   multiple keys.
#
# [*keyserver*]
#   The keyserver to use when download the key
#   Default: 'keyserver.ubuntu.com'
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
define aptly::mirror (
  $location,
  $key           = undef,
  $keyserver     = 'keyserver.ubuntu.com',
  $release       = $::lsbdistcodename,
  $architectures = [],
  $repos         = [],
  $with_sources  = false,
  $with_udebs    = false,
) {
  validate_string($keyserver)
  validate_array($repos)
  validate_array($architectures)
  validate_bool($with_sources)
  validate_bool($with_udebs)

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

  exec { "aptly_mirror_create-${title}":
    command => "${aptly_cmd} create ${architectures_arg} -with-sources=${with_sources} -with-udebs=${with_udebs} ${title} ${location} ${release}${components_arg}",
    unless  => "${aptly_cmd} show ${title} >/dev/null",
    user    => $::aptly::user,
    require => [
      Package['aptly'],
      File['/etc/aptly.conf'],
      Exec["aptly_mirror_gpg-${title}"],
    ],
  }
}
