# aptly

Puppet module for [aptly](http://www.aptly.info/).

## Example usage

You need to include the `apt` module if you wish to install it
out-of-the-box.
```
include apt
```

Include with default parameters:
```
include aptly
```

Create a mirror for manual update/snapshot/publish:
```
aptly::mirror { 'puppetlabs':
  location => 'http://apt.puppetlabs.com/',
  repos    => ['main', 'dependencies'],
  key      => '4BD6EC30',
}
```

See the class and defined type documentation for advanced usage.

## License

See [LICENSE](LICENSE) file.
