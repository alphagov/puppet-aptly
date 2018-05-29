require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|

  c.default_facts = {
    :operatingsystem        => 'Ubuntu',
    :operatingsystemrelease => 'trusty',
    :osfamily               => 'Debian',
    :lsbmajdistrelease      => 14,
  }

  # # This requires https://github.com/rspec/rspec-expectations/pull/951/files to work
  # c.expect_with :rspec do |r|
  #   r.max_formatted_output_length = nil # n is number of lines, or nil for no truncation.
  # end
end
