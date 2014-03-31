require 'spec_helper'

describe 'aptly' do
  let(:facts) {{
    :lsbdistid => 'Debian',
  }}

  context 'param defaults' do
    let(:params) {{ }}

    it { should contain_apt__source('aptly') }
    it { should contain_package('aptly').that_requires('Apt::Source[aptly]') }
  end
end
