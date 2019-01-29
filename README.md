# aptly 
Puppet module for [aptly](http://www.aptly.info/).

## Example usage

You need to include the `apt` module if you wish to install it
out-of-the-box.
```puppet
include apt
```

Include with default parameters:
```puppet
include aptly
```

Create a mirror for manual update/snapshot/publish:
```puppet
aptly::mirror { 'puppetlabs':
  location => 'http://apt.puppetlabs.com/',
  repos    => ['main', 'dependencies'],
  key      => '4BD6EC30',
}
```
or with the [puppetlabs/apt](https://forge.puppet.com/puppetlabs/apt)  module 2.0+ format
```puppet
aptly::mirror { 'puppetlabs':
  location => 'http://apt.puppetlabs.com/',
  repos    => ['main', 'dependencies'],
  key      =>  {
    server => 'keyserver.ubuntu.com',
    id     => '4BD6EC30',
  }
}
```

Create an aptly repository to host local packages:
```puppet
aptly::repo{ 'mylocalrepo': }
```

See the class and defined type documentation for advanced usage.

## License

See [LICENSE](LICENSE) file.
