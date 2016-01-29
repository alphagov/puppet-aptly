source 'https://rubygems.org'

# Versions can be overridden with environment variables for matrix testing.
# Travis will remove Gemfile.lock before installing deps.

gem 'puppet', ENV['PUPPET_VERSION'] || '~> 3.2.0'

gem 'rake', '10.4.2'
gem 'puppet-lint', '1.1.0'
gem 'rspec-puppet', '2.3.0'
gem 'rspec-system-puppet', '2.2.1'
gem 'puppetlabs_spec_helper', '0.9.1'
gem 'puppet-syntax', '2.0.0'

# Pin old versions of fog.
#
# rspec-system-puppet wants to install the later versions of fog, but they're
# not compatible with Ruby 1.9.3. To work around this pin to a version of fog
# (and fog-google) which is. We don't even use fog in this project but it's a
# dependency of the system tests.
gem 'fog', '1.34.0'
gem 'fog-google', '0.1.0'
