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

  describe '#config' do
    context 'not a hash' do
      let(:params) {{
        :config => 'this is a string',
      }}

      it { expect { should }.to raise_error(Puppet::Error, /is not a Hash/) }
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
{"rootDir":"/srv/aptly","architectures":["i386","amd64"]}
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

      it { expect { should }.to raise_error(Puppet::Error, /is not a boolean/) }
    end

    context 'false' do
      let(:params) {{
        :repo => false,
      }}

      it { should_not contain_apt__source('aptly') }
    end
  end
end
