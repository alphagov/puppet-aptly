# frozen_string_literal: true

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
    let(:params) { {} }

    it { is_expected.to contain_apt__source('aptly') }
    it { is_expected.to contain_package('aptly').that_requires('Class[Apt::Update]') }
    it { is_expected.to contain_file('/etc/aptly.conf').with_content("{}\n") }
  end

  describe '#package_ensure' do
    context 'present (default)' do
      let(:params) { {} }

      it { is_expected.to contain_package('aptly').with_ensure('present') }
    end

    context '1.2.3' do
      let(:params) do
        {
          package_ensure: '1.2.3'
        }
      end

      it { is_expected.to contain_package('aptly').with_ensure('1.2.3') }
    end
  end

  describe '#key_server (with #repo default to true)' do
    context 'custom key_server' do
      let(:params) do
        {
          key_server: 'keyserver.ubuntu.com'
        }
      end

      it 'overrides apt::source (somekeyserver.com)' do
        is_expected.to contain_apt__source('aptly').with(
          key: {
            'server' => 'keyserver.ubuntu.com',
            'id' => 'DF32BC15E2145B3FA151AED19E3E53F19C7DE460'
          },
        )
      end
    end
  end

  describe '#config_file' do
    context 'not an absolute path' do
      let(:params) do
        {
          config_file: 'relativepath/aptly.conf'
        }
      end

      it {
        is_expected.to raise_error(Puppet::PreformattedError, %r{parameter 'config_file' expects a .*Stdlib::{Absolute|Windows|Unix}path})
      }
    end

    context 'custom config path' do
      let(:params) do
        {
          config_file: '/etc/aptly/aptly.conf'
        }
      end

      it {
        is_expected.to contain_file('/etc/aptly/aptly.conf')
      }
    end
  end

  describe '#config' do
    context 'not a hash' do
      let(:params) do
        {
          config: 'this is a string'
        }
      end

      it {
        is_expected.to raise_error(Puppet::PreformattedError, %r{parameter 'config' expects a Hash value, got String})
      }
    end

    context 'rootDir and architectures' do
      let(:params) do
        {
          config: {
            'rootDir' => '/srv/aptly',
            'architectures' => ['i386', 'amd64']
          }
        }
      end

      it {
        is_expected.to contain_file('/etc/aptly.conf').with_content(<<EOS
{"architectures":["i386","amd64"],"rootDir":"/srv/aptly"}
EOS
                                                                   )
      }
    end
  end

  describe '#config_contents' do
    context 'not a string' do
      let(:params) do
        {
          config_contents: { 'a' => 1 }
        }
      end

      it {
        is_expected.to raise_error(Puppet::PreformattedError, %r{parameter 'config_contents' expects a value of type Undef or String, got Struct})
      }
    end

    context 'rootDir and architectures' do
      let(:params) do
        {
          config_contents: '{"rootDir":"/srv/aptly", "architectures":["i386", "amd64"]}'
        }
      end

      it {
        is_expected.to contain_file('/etc/aptly.conf').with_content(params[:config_contents])
      }
    end
  end

  describe '#repo' do
    context 'not a bool' do
      let(:params) do
        {
          repo: 'this is a string'
        }
      end

      it {
        is_expected.to raise_error(Puppet::PreformattedError, %r{parameter 'repo' expects a Boolean value, got String})
      }
    end

    context 'false' do
      let(:params) do
        {
          repo: false
        }
      end

      it { is_expected.not_to contain_apt__source('aptly') }
    end
  end
end
