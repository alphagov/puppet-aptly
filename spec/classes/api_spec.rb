require 'spec_helper'

describe 'aptly::api' do

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

      it { should raise_error(Puppet::Error, /Valid values for \$listen: :port, <ip>:<port>/) }
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
end
