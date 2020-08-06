# frozen_string_literal: true

require 'spec_helper'

describe 'aptly::repo' do
  let(:title) { 'example' }

  let(:facts) do
    {
      lsbdistid: 'ubuntu',
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

  describe 'param defaults' do
    it {
      is_expected.to contain_exec('aptly_repo_create-example').with(command: %r{aptly -config \/etc\/aptly.conf repo create *example},
                                                                    unless: %r{aptly -config \/etc\/aptly.conf repo show example >\/dev\/null},
                                                                    user: 'root',
                                                                    require: ['Package[aptly]', 'File[aptly_config_file]'])
    }
  end

  describe 'user defined component' do
    let(:params) do
      {
        component: 'third-party'
      }
    end

    it {
      is_expected.to contain_exec('aptly_repo_create-example').with(command: %r{aptly -config \/etc\/aptly.conf repo create *-component="third-party" *example},
                                                                    unless: %r{aptly -config \/etc\/aptly.conf repo show example >\/dev\/null},
                                                                    user: 'root',
                                                                    require: ['Package[aptly]', 'File[aptly_config_file]'])
    }

    context 'custom user' do
      let(:pre_condition) do
        <<-EOS
        class { 'aptly':
          user => 'custom_user',
        }
        EOS
      end

      let(:params) do
        {
          component: 'third-party'
        }
      end

      it {
        is_expected.to contain_exec('aptly_repo_create-example').with(command: %r{aptly -config \/etc\/aptly.conf repo create *-component="third-party" *example},
                                                                      unless: %r{aptly -config \/etc\/aptly.conf repo show example >\/dev\/null},
                                                                      user: 'custom_user',
                                                                      require: ['Package[aptly]', 'File[aptly_config_file]'])
      }
    end
  end

  describe 'user defined architectures' do
    context 'passing valid values' do
      let(:params) do
        {
          architectures: ['i386', 'amd64']
        }
      end

      it {
        is_expected.to contain_exec('aptly_repo_create-example').with(command: %r{aptly -config \/etc\/aptly.conf repo create *-architectures="i386,amd64" *example},
                                                                      unless: %r{aptly -config \/etc\/aptly.conf repo show example >\/dev\/null},
                                                                      user: 'root',
                                                                      require: ['Package[aptly]', 'File[aptly_config_file]'])
      }
    end

    context 'passing invalid values' do
      let(:params) do
        {
          architectures: 'amd64'
        }
      end

      it {
        is_expected.to raise_error(Puppet::PreformattedError, %r{parameter 'architectures' expects an Array value, got String})
      }
    end
  end

  describe 'user defined comment' do
    let(:params) do
      {
        comment: 'example comment'
      }
    end

    it {
      is_expected.to contain_exec('aptly_repo_create-example').with(command: %r{aptly -config \/etc\/aptly.conf repo create *-comment="example comment" *example},
                                                                    unless: %r{aptly -config \/etc\/aptly.conf repo show example >\/dev\/null},
                                                                    user: 'root',
                                                                    require: ['Package[aptly]', 'File[aptly_config_file]'])
    }
  end

  describe 'user defined distribution' do
    let(:params) do
      {
        distribution: 'example_distribution'
      }
    end

    it {
      is_expected.to contain_exec('aptly_repo_create-example').with(command: %r{aptly -config \/etc\/aptly.conf repo create *-distribution="example_distribution" *example},
                                                                    unless: %r{aptly -config \/etc\/aptly.conf repo show example >\/dev\/null},
                                                                    user: 'root',
                                                                    require: ['Package[aptly]', 'File[aptly_config_file]'])
    }
  end
end
