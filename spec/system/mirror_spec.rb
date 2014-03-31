require 'spec_helper_system'

describe 'mirror tests' do
  it 'class should work without errors and be idempotent' do
    pp = <<-EOS
      class { 'apt': }
      class { 'aptly': }

      aptly::mirror { 'puppetlabs':
        location => 'http://apt.puppetlabs.com/',
        key      => '4BD6EC30',
        release  => 'precise',
        repos    => ['main', 'dependencies'],
      }
    EOS

    puppet_apply(pp) do |r|
      r.exit_code.should == 2
      r.refresh
      r.exit_code.should be_zero
    end
  end

  it 'should have installed aptly' do
    shell 'aptly mirror show puppetlabs' do |r|
      r.stdout.should =~ /^Name: puppetlabs
Archive Root URL: http:\/\/apt\.puppetlabs\.com\/
Distribution: precise
Components: main, dependencies$/
      r.stderr.should be_empty
      r.exit_code.should be_zero
    end
  end
end
