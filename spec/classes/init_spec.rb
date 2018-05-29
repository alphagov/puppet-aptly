require 'spec_helper'

describe 'aptly' do
  let(:facts) do
    {
      lsbdistid: 'Debian',
      osfamily: 'Debian',
      os: {
        architecture: 'amd64',
        distro: {
          codename: 'stretch',
          description: 'Debian GNU/Linux 9.4 (stretch)',
          id: 'Debian',
          release: {
            full: '9.4',
            major: '9',
            minor: '4'
          }
        },
        family: 'Debian',
        hardware: 'x86_64',
        name: 'Debian',
        release: {
          full: '9.4',
          major: '9',
          minor: '4'
        },
        selinux: {
          enabled: false
        }
      }
    }
  end

  context 'param defaults' do
    let(:params) {{ }}

    it { should contain_apt__source('aptly') }
    it { should contain_package('aptly').that_requires('Class[Apt::Update]') }
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
    context 'custom key_server' do
      let(:params) {{
        :key_server => 'somekeyserver.com',
      }}

      it "should override apt::source (somekeyserver.com)" do
        should contain_apt__source('aptly').with(
          :key => {
            'server' => 'somekeyserver.com',
            'id' => '26DA9D8630302E0B86A7A2CBED75B5A4483DA07C'
          },
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
        should raise_error(Puppet::PreformattedError, /parameter 'config_file' expects a .*Stdlib::{Absolute|Windows|Unix}path/)
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
        should raise_error(Puppet::PreformattedError, /parameter 'config' expects a Hash value, got String/)
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

  describe '#config_contents' do
    context 'not a string' do
      let(:params) {{
         :config_contents => { 'a' => 1 }
      }}
      it {
        should raise_error(Puppet::PreformattedError, /parameter 'config_contents' expects a value of type Undef or String, got Struct/)
      }
    end

    context 'rootDir and architectures' do
      let(:params) {{
        :config_contents => '{"rootDir":"/srv/aptly", "architectures":["i386", "amd64"]}'
      }}

      it {
        should contain_file('/etc/aptly.conf').with_content(params[:config_contents])
      }
    end
  end

  describe '#repo' do
    context 'not a bool' do
      let(:params) {{
        :repo => 'this is a string',
      }}

      it {
        should raise_error(Puppet::PreformattedError, /parameter 'repo' expects a Boolean value, got String/)
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
