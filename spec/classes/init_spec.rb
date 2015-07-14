require 'spec_helper'

describe 'aptly' do
  let(:facts) {{
    :lsbdistid => 'Debian',
  }}

  context 'param defaults' do
    let(:params) {{ }}

    it { should contain_apt__source('aptly') }
    it { should contain_package('aptly').that_requires('Apt::Source[aptly]') }
    it { should contain_file('/etc/aptly.conf').with_content("{}\n") }
  end

  describe '#package_ensure' do
    context 'present (default)' do
      let(:params) {{ }}

      it { should contain_package('aptly').with_ensure('present') }
    end

    context '1.2.3' do
      let(:params) {{
        :package_ensure => '1.2.3',
      }}

      it { should contain_package('aptly').with_ensure('1.2.3') }
    end
  end

  describe '#key_server (with #repo default to true)' do
    context "undef (default)" do
      let(:params) {{ }}

      it "should let apt::source decide the default (keyserver.ubuntu.com)" do
        should contain_apt__source('aptly').with(
          :key_server => 'keyserver.ubuntu.com',
        )
      end
    end

    context 'custom key_server' do
      let(:params) {{
        :key_server => 'somekeyserver.com',
      }}

      it "should override apt::source (somekeyserver.com)" do
        should contain_apt__source('aptly').with(
          :key_server => 'somekeyserver.com',
        )
      end
    end
  end

  describe '#config_file' do
    context 'not an absolute path' do
      let(:params) {{
        :config_file => 'relativepath/aptly.conf',
      }}

      it {
        should raise_error(Puppet::Error, /is not an absolute path/)
      }
    end

    context 'custom config path' do
      let(:params) {{
        :config_file => '/etc/aptly/aptly.conf',
      }}

      it {
        should contain_file('/etc/aptly/aptly.conf')
      }
    end
  end

  describe '#config' do
    context 'not a hash' do
      let(:params) {{
        :config => 'this is a string',
      }}

      it {
        should raise_error(Puppet::Error, /is not a Hash/)
      }
    end

    context 'rootDir and architectures' do
      let(:params) {{
        :config => {
          'rootDir'       => '/srv/aptly',
          'architectures' => ['i386', 'amd64'],
        },
      }}

      it {
        should contain_file('/etc/aptly.conf').with_content(<<EOS
{"architectures":["i386","amd64"],"rootDir":"/srv/aptly"}
EOS
        )
      }
    end
  end

  describe '#repo' do
    context 'not a bool' do
      let(:params) {{
        :repo => 'this is a string',
      }}

      it {
        should raise_error(Puppet::Error, /is not a boolean/)
      }
    end

    context 'false' do
      let(:params) {{
        :repo => false,
      }}

      it { should_not contain_apt__source('aptly') }
    end
  end
end
