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
#   This can either be a key id or a hash including key options. 
#   If using a hash, key => { 'id' => <id> } must be specified
#   Default: {}
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
  String $location,
  Variant[String, Hash] $key = {},
  String $keyring            = '/etc/apt/trusted.gpg',
  String $filter             = '',
  String $release            = $::lsbdistcodename,
  Array $architectures       = [],
  Array $repos               = [],
  Boolean $with_sources      = false,
  Boolean $with_udebs        = false,
  Boolean $filter_with_deps  = false,
  Array $environment         = [],
) {
  include ::aptly

  $gpg_cmd = "/usr/bin/gpg --no-default-keyring --keyring ${keyring}"
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
    $filter_arg = " -filter=\"${filter}\""
  }

  if ($filter_with_deps == true) {
    $filter_with_deps_arg = ' -filter-with-deps'
  } else{
    $filter_with_deps_arg = ''
  }

  # $::aptly::key_server will be used as default key server
  # key in hash format
  if is_hash($key) and $key[id] {
    if is_array($key[id]) {
      $key_string = join($key[id], "' '")
    } elsif is_string($key[id]) or is_integer($key[id]) {
      $key_string = $key[id]
    } else {
      fail('$key[id] is neither a string nor an array!')
    }
    if $key[server] {
      $key_server = $key[server]
    }else{
      $key_server = $::aptly::key_server
    }

  # key in string/array format
  }elsif is_string($key) or is_array($key) {
    $key_server = $::aptly::key_server
    if is_array($key) {
      $key_string = join($key, "' '")
    } elsif is_string($key) or is_integer($key) {
      $key_string = $key
    } else {
      fail('$key is neither a string nor an array!')
    }
  }

  # no GPG key
  if $key.empty {
    $exec_aptly_mirror_create_require = [
      Package['aptly'],
      File['aptly_config_file'],
    ]
  }else{
    exec { "aptly_mirror_gpg-${title}":
      path    => '/bin:/usr/bin',
      command => "${gpg_cmd} --keyserver '${key_server}' --recv-keys '${key_string}'",
      unless  => "echo '${key_string}' | xargs -n1 ${gpg_cmd} --list-keys",
      user    => $::aptly::user,
    }

    $exec_aptly_mirror_create_require = [
      Package['aptly'],
      File['aptly_config_file'],
      Exec["aptly_mirror_gpg-${title}"],
    ]
  }

  exec { "aptly_mirror_create-${title}":
    command     => "${aptly_cmd} create ${architectures_arg} -with-sources=${with_sources} -with-udebs=${with_udebs}${filter_arg}${filter_with_deps_arg} ${title} ${location} ${release}${components_arg}",
    unless      => "${aptly_cmd} show ${title} >/dev/null",
    user        => $::aptly::user,
    require     => $exec_aptly_mirror_create_require,
    environment => $environment,
  }
}
