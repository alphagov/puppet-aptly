require 'spec_helper'

describe 'aptly::mirror' do
  let(:title) { 'example' }
  let(:facts) {{
    :lsbdistid       => 'Debian',
    :lsbdistcodename => 'precise',
  }}

  describe 'param defaults and mandatory' do
    let(:params) {{
      :location => 'http://repo.example.com',
      :key      => 'ABC123',
    }}

    it {
      should contain_exec('aptly_mirror_key-ABC123').with({
        :command => / --keyserver 'keyserver.ubuntu.com' --recv-keys 'ABC123'$/,
        :unless  => / --list-keys 'ABC123'$/,
        :user    => 'root',
      })
    }

    it {
      should contain_exec('aptly_mirror_create-example').with({
        :command => /aptly mirror create example http:\/\/repo\.example\.com precise$/,
        :unless  => /aptly mirror show example >\/dev\/null$/,
        :user    => 'root',
        :require => [
          'Class[Aptly]',
          'Exec[aptly_mirror_key-ABC123]'
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

      it { should contain_exec('aptly_mirror_key-ABC123') }
    end
  end

  describe '#user' do
    context 'with custom user' do
      let(:params){{
        :location => 'http://repo.example.com',
        :key      => 'ABC123',
      }}

      let(:pre_condition)  { 'class { "aptly": user => "custom_user" }' }
      it { 
        should contain_exec('aptly_mirror_key-ABC123').with({
          :command => / --keyserver 'keyserver.ubuntu.com' --recv-keys 'ABC123'$/,
          :unless  => / --list-keys 'ABC123'$/,
          :user    => 'custom_user',
        })
      }

    it {
      should contain_exec('aptly_mirror_create-example').with({
        :command => /aptly mirror create example http:\/\/repo\.example\.com precise$/,
        :unless  => /aptly mirror show example >\/dev\/null$/,
        :user    => 'custom_user',
        :require => [
          'Class[Aptly]',
          'Exec[aptly_mirror_key-ABC123]'
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
        should contain_exec('aptly_mirror_key-ABC123').with({
          :command => / --keyserver 'hkp:\/\/repo.keyserver.com:80' --recv-keys 'ABC123'$/,
          :unless  => / --list-keys 'ABC123'$/,
          :user    => 'root',
        })
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

      it { expect { should }.to raise_error(Puppet::Error, /is not an Array/) }
    end

    context 'single item' do
      let(:params) {{
        :location => 'http://repo.example.com',
        :key      => 'ABC123',
        :repos    => ['main'],
      }}

      it {
        should contain_exec('aptly_mirror_create-example').with_command(
          /aptly mirror create example http:\/\/repo\.example\.com precise main$/
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
          /aptly mirror create example http:\/\/repo\.example\.com precise main contrib non-free$/
        )
      }
    end
  end
end
