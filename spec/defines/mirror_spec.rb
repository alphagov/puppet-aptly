require 'spec_helper'

describe 'aptly::mirror' do
  let(:title) { 'example' }
  let(:facts) {{
    lsbdistid: 'Debian',
    lsbdistcodename: 'precise',
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
  }}

  describe 'param defaults and mandatory' do
    let(:params) {{
      :location => 'http://repo.example.com',
      :key      => 'ABC123',
    }}

    it {
      should contain_exec('aptly_mirror_gpg-example').with({
        :command => / --keyserver 'keyserver.ubuntu.com' --recv-keys 'ABC123'$/,
        :unless  => /^echo 'ABC123' |/,
        :user    => 'root',
      })
    }

    it {
      should contain_exec('aptly_mirror_create-example').with({
        :command => /aptly -config \/etc\/aptly.conf mirror create *-with-sources=false -with-udebs=false example http:\/\/repo\.example\.com precise$/,
        :unless  => /aptly -config \/etc\/aptly.conf mirror show example >\/dev\/null$/,
        :user    => 'root',
        :require => [
          'Package[aptly]',
          'File[/etc/aptly.conf]',
          'Exec[aptly_mirror_gpg-example]'
        ],
      })
    }

    context 'two repos with same key' do
      let(:pre_condition) { <<-EOS
        aptly::mirror { 'example-lucid':
          location => 'http://lucid.example.com/',
          key      => 'ABC123',
        }
        EOS
      }

      it { should contain_exec('aptly_mirror_gpg-example-lucid') }
    end
  end

  describe '#user' do
    context 'with custom user' do
      let(:pre_condition)  { <<-EOS
        class { 'aptly':
          user => 'custom_user',
        }
        EOS
      }

      let(:params){{
        :location => 'http://repo.example.com',
        :key      => 'ABC123',
      }}

      it {
        should contain_exec('aptly_mirror_gpg-example').with({
          :command => / --keyserver 'keyserver.ubuntu.com' --recv-keys 'ABC123'$/,
          :unless  => /^echo 'ABC123' |/,
          :user    => 'custom_user',
        })
      }

      it {
        should contain_exec('aptly_mirror_create-example').with({
          :command => /aptly -config \/etc\/aptly.conf mirror create *-with-sources=false -with-udebs=false example http:\/\/repo\.example\.com precise$/,
          :unless  => /aptly -config \/etc\/aptly.conf mirror show example >\/dev\/null$/,
          :user    => 'custom_user',
          :require => [
            'Package[aptly]',
            'File[/etc/aptly.conf]',
            'Exec[aptly_mirror_gpg-example]'
          ],
        })
      }
    end
  end

  describe '#keyserver' do
    context 'with custom keyserver' do
      let(:params){{
        :location   => 'http://repo.example.com',
        :key        => 'ABC123',
        :keyserver  => 'hkp://repo.keyserver.com:80',
      }}

      it{
        should contain_exec('aptly_mirror_gpg-example').with({
          :command => / --keyserver 'hkp:\/\/repo.keyserver.com:80' --recv-keys 'ABC123'$/,
          :unless  => /^echo 'ABC123' |/,
          :user    => 'root',
        })
      }
    end
  end

  describe '#environment' do
    context 'not an array' do
      let(:params){{
        :location    => 'http://repo.example.com',
        :key         => 'ABC123',
        :environment => 'FOO=bar',
      }}

      it {
        should raise_error(Puppet::Error, /is not an Array/)
      }
    end

    context 'defaults to empty array' do
      let(:params){{
        :location    => 'http://repo.example.com',
        :key         => 'ABC123',
      }}

      it {
        should contain_exec('aptly_mirror_create-example').with({
          :environment => [],
        })
      }
    end

    context 'with FOO set to bar' do
      let(:params){{
        :location    => 'http://repo.example.com',
        :key         => [ 'ABC123' ],
        :environment => ['FOO=bar'],
      }}

      it{
        should contain_exec('aptly_mirror_create-example').with({
          :environment => ['FOO=bar'],
        })
      }
    end
  end

  describe '#key' do
    context 'single item not in an array' do
      let(:params){{
        :location   => 'http://repo.example.com',
        :key        => 'ABC123',
      }}

      it{
        should contain_exec('aptly_mirror_gpg-example').with({
          :command => / --keyserver 'keyserver.ubuntu.com' --recv-keys 'ABC123'$/,
          :unless  => /^echo 'ABC123' |/,
        })
      }
    end

    context 'single item in an array' do
      let(:params){{
        :location   => 'http://repo.example.com',
        :key        => [ 'ABC123' ],
      }}

      it{
        should contain_exec('aptly_mirror_gpg-example').with({
          :command => / --keyserver 'keyserver.ubuntu.com' --recv-keys 'ABC123'$/,
          :unless  => /^echo 'ABC123' |/,
        })
      }
    end

    context 'multiple items' do
      let(:params){{
        :location   => 'http://repo.example.com',
        :key        => [ 'ABC123', 'DEF456', 'GHI789' ],
      }}

      it{
        should contain_exec('aptly_mirror_gpg-example').with({
          :command => / --keyserver 'keyserver.ubuntu.com' --recv-keys 'ABC123' 'DEF456' 'GHI789'$/,
          :unless  => /^echo 'ABC123' 'DEF456' 'GHI789' |/,
        })
      }
    end

    context 'no key passed' do
      let(:params) {
        {
          :location => 'http://repo.example.com',
        }
      }

      it {
        should_not contain_exec('aptly_mirror_gpg-example')
      }
    end
  end

  describe '#repos' do
    context 'not an array' do
      let(:params) {{
        :location => 'http://repo.example.com',
        :key      => 'ABC123',
        :repos    => 'this is a string',
      }}

      it {
        should raise_error(Puppet::Error, /is not an Array/)
      }
    end

    context 'single item' do
      let(:params) {{
        :location => 'http://repo.example.com',
        :key      => 'ABC123',
        :repos    => ['main'],
      }}

      it {
        should contain_exec('aptly_mirror_create-example').with_command(
          /aptly -config \/etc\/aptly.conf mirror create *-with-sources=false -with-udebs=false example http:\/\/repo\.example\.com precise main$/
        )
      }
    end

    context 'multiple items' do
      let(:params) {{
        :location => 'http://repo.example.com',
        :key      => 'ABC123',
        :repos    => ['main', 'contrib', 'non-free'],
      }}

      it {
        should contain_exec('aptly_mirror_create-example').with_command(
          /aptly -config \/etc\/aptly.conf mirror create *-with-sources=false -with-udebs=false example http:\/\/repo\.example\.com precise main contrib non-free$/
        )
      }
    end
  end

  describe '#architectures' do
    context 'not an array' do
      let(:params) {{
        :location      => 'http://repo.example.com',
        :key           => 'ABC123',
        :architectures => 'this is a string',
      }}

      it {
        should raise_error(Puppet::Error, /is not an Array/)
      }
    end

    context 'single item' do
      let(:params) {{
	:location      => 'http://repo.example.com',
	:key           => 'ABC123',
	:architectures => ['amd64'],
      }}

      it {
	should contain_exec('aptly_mirror_create-example').with_command(
	  /aptly -config \/etc\/aptly.conf mirror create -architectures="amd64" -with-sources=false -with-udebs=false example http:\/\/repo\.example\.com precise$/
	)
      }
    end

    context 'multiple items' do
      let(:params) {{
        :location      => 'http://repo.example.com',
        :key           => 'ABC123',
        :architectures => ['i386', 'amd64','armhf'],
      }}

      it {
        should contain_exec('aptly_mirror_create-example').with_command(
          /aptly -config \/etc\/aptly.conf mirror create -architectures="i386,amd64,armhf" -with-sources=false -with-udebs=false example http:\/\/repo\.example\.com precise$/
        )
      }
    end
  end

  describe '#with_sources' do
    context 'not a boolean' do
      let(:params) {{
        :location     => 'http://repo.example.com',
        :key          => 'ABC123',
        :with_sources => 'this is a string',
      }}

      it {
        should raise_error(Puppet::Error, /is not a boolean/)
      }
    end

    context 'with boolean true' do
      let(:params) {{
        :location     => 'http://repo.example.com',
        :key          => 'ABC123',
        :with_sources => true,
      }}

      it {
        should contain_exec('aptly_mirror_create-example').with_command(
          /aptly -config \/etc\/aptly.conf mirror create *-with-sources=true -with-udebs=false example http:\/\/repo\.example\.com precise$/
        )
      }
    end
  end

  describe '#with_udebs' do
    context 'not a boolean' do
      let(:params) {{
        :location   => 'http://repo.example.com',
        :key        => 'ABC123',
        :with_udebs => 'this is a string',
      }}

      it {
        should raise_error(Puppet::Error, /is not a boolean/)
      }
    end

    context 'with boolean true' do
      let(:params) {{
        :location   => 'http://repo.example.com',
        :key        => 'ABC123',
        :with_udebs => true,
      }}

      it {
        should contain_exec('aptly_mirror_create-example').with_command(
          /aptly -config \/etc\/aptly.conf mirror create *-with-sources=false -with-udebs=true example http:\/\/repo\.example\.com precise$/
        )
      }
    end
  end

  describe '#filter_with_deps' do
    context 'not a boolean' do
      let(:params) {{
        :location         => 'http://repo.example.com',
        :key              => 'ABC123',
        :filter_with_deps => 'this is a string',
      }}

      it {
        should raise_error(Puppet::Error, /is not a boolean/)
      }
    end

    context 'with boolean true' do
      let(:params) {{
        :location         => 'http://repo.example.com',
        :key              => 'ABC123',
        :filter_with_deps => true,
      }}

      it {
        should contain_exec('aptly_mirror_create-example').with_command(
          /aptly -config \/etc\/aptly.conf mirror create *-with-sources=false -with-udebs=false -filter-with-deps example http:\/\/repo\.example\.com precise$/
        )
      }
    end
  end

  describe '#filter' do
    context 'with filter' do
      let(:params){{
        :location   => 'http://repo.example.com',
        :key        => 'ABC123',
        :filter     => 'this is a string',
      }}
  
      it {
        should contain_exec('aptly_mirror_create-example').with_command(
          /aptly -config \/etc\/aptly.conf mirror create *-with-sources=false -with-udebs=false -filter="this is a string" example http:\/\/repo\.example\.com precise$/
        )
      }
    end
  end

end
