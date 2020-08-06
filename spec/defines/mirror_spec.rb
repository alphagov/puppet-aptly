# frozen_string_literal: true

require 'spec_helper'

describe 'aptly::mirror' do
  let(:title) { 'example' }
  let(:facts) do
    {
      lsbdistid: 'Debian',
      lsbdistcodename: 'precise',
      osfamily: 'Debian',
      os: {
        name: 'Debian',
        release: {
          full: '9.4',
          major: '9',
          minor: '4'
        }
      }
    }
  end

  describe 'param defaults and mandatory' do
    let(:params) do
      {
        location: 'http://repo.example.com',
        key: {
          id: 'ABC123',
          server: 'keyserver.ubuntu.com'
        }
      }
    end

    it {
      is_expected.to contain_exec('aptly_mirror_gpg-example').with(command: %r{ --keyserver 'keyserver.ubuntu.com' --recv-keys 'ABC123'$},
                                                                   unless: %r{^echo 'ABC123' |},
                                                                   user: 'root')
    }

    it {
      is_expected.to contain_exec('aptly_mirror_create-example').with(command: %r{aptly -config \/etc\/aptly.conf mirror create *-with-sources=false -with-udebs=false example http:\/\/repo\.example\.com precise$},
                                                                      unless: %r{aptly -config \/etc\/aptly.conf mirror show example >\/dev\/null$},
                                                                      user: 'root',
                                                                      require: [
                                                                        'Package[aptly]',
                                                                        'File[aptly_config_file]',
                                                                        'Exec[aptly_mirror_gpg-example]'
                                                                      ])
    }

    context 'two repos with same key' do
      let(:params) do
        {
          location: 'http://lucid.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          }
        }
      end

      it {
        is_expected.to contain_exec('aptly_mirror_gpg-example').with(command: %r{ --keyserver 'keyserver.ubuntu.com' --recv-keys 'ABC123'$},
                                                                     unless: %r{^echo 'ABC123' |},
                                                                     user: 'root')
      }

      it {
        is_expected.to contain_exec('aptly_mirror_create-example').with(command: %r{aptly -config \/etc\/aptly.conf mirror create *-with-sources=false -with-udebs=false example http:\/\/lucid\.example\.com precise$},
                                                                        unless: %r{aptly -config \/etc\/aptly.conf mirror show example >\/dev\/null$},
                                                                        user: 'root',
                                                                        require: [
                                                                          'Package[aptly]',
                                                                          'File[aptly_config_file]',
                                                                          'Exec[aptly_mirror_gpg-example]'
                                                                        ])
      }
    end
  end

  describe '#user' do
    context 'with custom user' do
      let(:pre_condition) do
        <<-EOS
        class { 'aptly':
          user => 'custom_user',
        }
        EOS
      end

      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          }
        }
      end

      it {
        is_expected.to contain_exec('aptly_mirror_gpg-example').with(command: %r{ --keyserver 'keyserver.ubuntu.com' --recv-keys 'ABC123'$},
                                                                     unless: %r{^echo 'ABC123' |},
                                                                     user: 'custom_user')
      }

      it {
        is_expected.to contain_exec('aptly_mirror_create-example').with(command: %r{aptly -config \/etc\/aptly.conf mirror create *-with-sources=false -with-udebs=false example http:\/\/repo\.example\.com precise$},
                                                                        unless: %r{aptly -config \/etc\/aptly.conf mirror show example >\/dev\/null$},
                                                                        user: 'custom_user',
                                                                        require: [
                                                                          'Package[aptly]',
                                                                          'File[aptly_config_file]',
                                                                          'Exec[aptly_mirror_gpg-example]'
                                                                        ])
      }
    end
  end

  describe '#keyserver' do
    context 'with custom keyserver' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          }
        }
      end

      it {
        is_expected.to contain_exec('aptly_mirror_gpg-example').with(command: %r{ --keyserver 'keyserver.ubuntu.com' --recv-keys 'ABC123'$},
                                                                     unless: %r{^echo 'ABC123' |},
                                                                     user: 'root')
      }
    end
  end

  describe '#environment' do
    context 'not an array' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          },
          environment: 'FOO=bar'
        }
      end

      it {
        is_expected.to raise_error(Puppet::Error, %r{expects an Array value})
      }
    end

    context 'defaults to empty array' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          }
        }
      end

      it {
        is_expected.to contain_exec('aptly_mirror_create-example').with(environment: [])
      }
    end

    context 'with FOO set to bar' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          },
          environment: ['FOO=bar']
        }
      end

      it {
        is_expected.to contain_exec('aptly_mirror_create-example').with(environment: ['FOO=bar'])
      }
    end
  end

  describe '#key' do
    context 'single item not in an array' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          }
        }
      end

      it {
        is_expected.to contain_exec('aptly_mirror_gpg-example').with(command: %r{ --keyserver 'keyserver.ubuntu.com' --recv-keys 'ABC123'$},
                                                                     unless: %r{^echo 'ABC123' |})
      }
    end

    context 'single item in an array' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          }
        }
      end

      it {
        is_expected.to contain_exec('aptly_mirror_gpg-example').with(command: %r{ --keyserver 'keyserver.ubuntu.com' --recv-keys 'ABC123'$},
                                                                     unless: %r{^echo 'ABC123' |})
      }
    end

    context 'multiple items' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: ['ABC123', 'DEF456', 'GHI789'],
            server: 'keyserver.ubuntu.com'
          }
        }
      end

      it {
        is_expected.to contain_exec('aptly_mirror_gpg-example').with(command: %r{ --keyserver 'keyserver.ubuntu.com' --recv-keys 'ABC123' 'DEF456' 'GHI789'$},
                                                                     unless: %r{^echo 'ABC123' 'DEF456' 'GHI789' |})
      }
    end

    context 'no key passed' do
      let(:params) do
        {
          location: 'http://repo.example.com'
        }
      end

      it {
        is_expected.not_to contain_exec('aptly_mirror_gpg-example')
      }
    end
  end

  describe '#repos' do
    context 'not an array' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          },
          repos: 'this is a string'
        }
      end

      it {
        is_expected.to raise_error(Puppet::Error, %r{expects an Array value})
      }
    end

    context 'single item' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          },
          repos: ['main']
        }
      end

      it {
        is_expected.to contain_exec('aptly_mirror_create-example').with_command(
          %r{aptly -config \/etc\/aptly.conf mirror create *-with-sources=false -with-udebs=false example http:\/\/repo\.example\.com precise main},
        )
      }
    end

    context 'multiple items' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          },
          repos: ['main', 'contrib', 'non-free']
        }
      end

      it {
        is_expected.to contain_exec('aptly_mirror_create-example').with_command(
          %r{aptly -config \/etc\/aptly.conf mirror create *-with-sources=false -with-udebs=false example http:\/\/repo\.example\.com precise main contrib non-free},
        )
      }
    end
  end

  describe '#architectures' do
    context 'not an array' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          },
          architectures: 'this is a string'
        }
      end

      it {
        is_expected.to raise_error(Puppet::Error, %r{expects an Array value})
      }
    end

    context 'single item' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          },
          architectures: ['amd64']
        }
      end

      it {
        is_expected.to contain_exec('aptly_mirror_create-example').with_command(
          %r{aptly -config \/etc\/aptly.conf mirror create -architectures="amd64" -with-sources=false -with-udebs=false example http:\/\/repo\.example\.com precise},
        )
      }
    end

    context 'multiple items' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          },
          architectures: ['i386', 'amd64', 'armhf']
        }
      end

      it {
        is_expected.to contain_exec('aptly_mirror_create-example').with_command(
          %r{aptly -config \/etc\/aptly.conf mirror create -architectures="i386,amd64,armhf" -with-sources=false -with-udebs=false example http:\/\/repo\.example\.com precise},
        )
      }
    end
  end

  describe '#with_sources' do
    context 'not a boolean' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          },
          with_sources: 'this is a string'
        }
      end

      it {
        is_expected.to raise_error(Puppet::Error, %r{expects a Boolean value})
      }
    end

    context 'with boolean true' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          },
          with_sources: true
        }
      end

      it {
        is_expected.to contain_exec('aptly_mirror_create-example').with_command(
          %r{aptly -config \/etc\/aptly.conf mirror create *-with-sources=true -with-udebs=false example http:\/\/repo\.example\.com precise},
        )
      }
    end
  end

  describe '#with_udebs' do
    context 'not a boolean' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          },
          with_udebs: 'this is a string'
        }
      end

      it {
        is_expected.to raise_error(Puppet::Error, %r{expects a Boolean value})
      }
    end

    context 'with boolean true' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          },
          with_udebs: true
        }
      end

      it {
        is_expected.to contain_exec('aptly_mirror_create-example').with_command(%r{aptly -config \/etc\/aptly.conf mirror create *-with-sources=false -with-udebs=true example http:\/\/repo\.example\.com precise})
      }
    end
  end

  describe '#filter_with_deps' do
    context 'not a boolean' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          },
          filter_with_deps: 'this is a string'
        }
      end

      it {
        is_expected.to raise_error(Puppet::Error, %r{expects a Boolean value})
      }
    end

    context 'with boolean true' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          },
          filter_with_deps: true
        }
      end

      it {
        is_expected.to contain_exec('aptly_mirror_create-example').with_command(
          %r{aptly -config \/etc\/aptly.conf mirror create *-with-sources=false -with-udebs=false -filter-with-deps example http:\/\/repo\.example\.com precise},
        )
      }
    end
  end

  describe '#filter' do
    context 'with filter' do
      let(:params) do
        {
          location: 'http://repo.example.com',
          key: {
            id: 'ABC123',
            server: 'keyserver.ubuntu.com'
          },
          filter: 'this is a string'
        }
      end

      it {
        is_expected.to contain_exec('aptly_mirror_create-example').with_command(
          %r{aptly -config \/etc\/aptly.conf mirror create *-with-sources=false -with-udebs=false -filter="this is a string" example http:\/\/repo\.example\.com precise},
        )
      }
    end
  end
end
