require 'spec_helper'

describe 'aptly::api' do
  context 'Using Systemd' do
    let(:facts) do
      {
        operatingsystem: 'Debian',
        operatingsystemrelease: '8.7',
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

      it do
        should contain_file('aptly-systemd')
        .with_path('/etc/systemd/system/aptly-api.service')
        .without_content(/^\s*author /)
        .with_content(/^User=root$/)
        .with_content(/^Group=root$/)
        .with_content(/^ExecStart=\/usr\/bin\/aptly api serve -listen=:8080$/)
        .that_notifies('Service[aptly-api]')
      end
      it do
        should contain_service('aptly-api')
        .with_ensure('running')
        .with_enable(true)
      end
    end

    describe 'ensure' do
      context 'present (default)' do
        let(:params) {{ }}

        it { should contain_service('aptly-api').with_ensure('running') }
      end

      context 'stopped' do
        let(:params) {{
          :ensure => 'stopped'
        }}

        it { should contain_service('aptly-api').with_ensure('stopped') }
      end

      context 'invalid value' do
        let(:params) {{
          :ensure => 'yolo'
        }}

        it { should raise_error(Puppet::Error, /Valid values for \$ensure: stopped, running/) }
      end
    end

    describe 'user' do
      context 'custom' do
        let(:params) {{
          :user => 'yolo'
        }}

        it { should contain_file('aptly-systemd').with_content(/^User=yolo$/) }
      end

      context 'not a string' do
        let(:params) {{
          :user => false
        }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end

    describe 'group' do
      context 'custom' do
        let(:params) {{
          :group => 'yolo'
        }}

        it { should contain_file('aptly-systemd').with_content(/^Group=yolo$/) }
      end

      context 'not a string' do
        let(:params) {{
          :group => false
        }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end

    describe 'listen' do
      context 'custom' do
        let(:params) {{
          :listen => '127.0.0.1:9090'
        }}

        it { should contain_file('aptly-systemd').with_content(/^ExecStart=\/usr\/bin\/aptly api serve -listen=127.0.0.1:9090$/) }
      end

      context 'not a string' do
        let(:params) {{
          :listen => false
        }}

        it { should raise_error(Puppet::Error, /input needs to be a String/) }
      end

      context 'invalid format' do
        let(:params) {{
          :listen => 'yolo'
        }}

        it { should raise_error(Puppet::Error, /Valid values for \$listen: :port, <ip>:<port>/) }
      end
    end

    describe 'log' do
      context 'invalid value' do
        let(:params) {{
          :log => 'yolo'
        }}

        it { should raise_error(Puppet::Error, /Valid values for \$log: none, log/) }
      end
    end

    describe 'enable_cli_and_http' do
      context 'false (default)' do
        it { should contain_file('aptly-systemd').without_content(/ -no-lock/) }
      end

      context 'true' do
        let(:params) {{
          :enable_cli_and_http => true
        }}

        it { should contain_file('aptly-systemd').with_content(/ -no-lock/) }
      end
    end
  end

  context 'Using Upstart' do
    let(:facts) do
      {
        :operatingsystem => 'Ubuntu',
        :operatingsystemrelease => '15.03',
        os: {
          name: 'Ubuntu',
          release: {
            full: '15.03'
          }
        }
      }
    end

    context 'param defaults' do
      let(:params) {{ }}

      it do
        should contain_file('aptly-upstart')
        .with_path('/etc/init/aptly-api.conf')
        .without_content(/^\s*author /)
        .with_content(/^setuid root$/)
        .with_content(/^setgid root$/)
        .with_content(/^exec \/usr\/bin\/aptly api serve -listen=:8080$/)
        .that_notifies('Service[aptly-api]')
      end

      it do
        should contain_service('aptly-api')
        .with_ensure('running')
        .with_enable(true)
      end
    end

    describe 'ensure' do
      context 'present (default)' do
        let(:params) {{ }}

        it { should contain_service('aptly-api').with_ensure('running') }
      end

      context 'stopped' do
        let(:params) {{
          :ensure => 'stopped'
        }}

        it { should contain_service('aptly-api').with_ensure('stopped') }
      end

      context 'invalid value' do
        let(:params) {{
          :ensure => 'yolo'
        }}

        it { should raise_error(Puppet::Error, /Valid values for \$ensure: stopped, running/) }
      end
    end

    describe 'user' do
      context 'custom' do
        let(:params) {{
          :user => 'yolo'
        }}

        it { should contain_file('aptly-upstart').with_content(/^setuid yolo$/) }
      end

      context 'not a string' do
        let(:params) {{
          :user => false
        }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end

    describe 'group' do
      context 'custom' do
        let(:params) {{
          :group => 'yolo'
        }}

        it { should contain_file('aptly-upstart').with_content(/^setgid yolo$/) }
      end

      context 'not a string' do
        let(:params) {{
          :group => false
        }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end

    describe 'listen' do
      context 'custom' do
        let(:params) {{
          :listen => '127.0.0.1:9090'
        }}

        it { should contain_file('aptly-upstart').with_content(/^exec \/usr\/bin\/aptly api serve -listen=127.0.0.1:9090$/) }
      end

      context 'not a string' do
        let(:params) {{
          :listen => false
        }}

        it { should raise_error(Puppet::Error, /input needs to be a String/) }
      end

      context 'invalid format' do
        let(:params) {{
          :listen => 'yolo'
        }}

        it { should raise_error(Puppet::Error, /Valid values for \$listen: :port, <ip>:<port>/) }
      end
    end

    describe 'log' do
      context 'none (default)' do
        let(:params) {{ }}

        it { should contain_file('aptly-upstart').with_content(/^console none$/) }
      end

      context 'log' do
        let(:params) {{
          :log => 'log'
        }}

        it { should contain_file('aptly-upstart').with_content(/^console log$/) }
      end

      context 'invalid value' do
        let(:params) {{
          :log => 'yolo'
        }}

        it { should raise_error(Puppet::Error, /Valid values for \$log: none, log/) }
      end
    end

    describe 'enable_cli_and_http' do
      context 'false (default)' do
        it { should contain_file('aptly-upstart').without_content(/ -no-lock/) }
      end

      context 'true' do
        let(:params) {{
          :enable_cli_and_http => true
        }}

        it { should contain_file('aptly-upstart').with_content(/ -no-lock/) }
      end
    end
  end
end
