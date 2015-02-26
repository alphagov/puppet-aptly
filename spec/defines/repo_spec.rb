require 'spec_helper'

describe 'aptly::repo' do
  let(:title) { 'example' }

  let(:facts){{
    :lsbdistid => 'ubuntu',
  }}

  describe 'param defaults' do
    it {
        should contain_exec('aptly_repo_create-example').with({
          :command  => /aptly repo create  example$/,
          :unless   => /aptly repo show example >\/dev\/null$/,
          :user     => 'root',
          :require  => 'Class[Aptly]',
      })
    }
  end

  describe 'user defined component' do
    let(:params){{
      :component => 'third-party',
    }}

    it {
        should contain_exec('aptly_repo_create-example').with({
          :command  => /aptly repo create -component="third-party" example$/,
          :unless   => /aptly repo show example >\/dev\/null$/,
          :user     => 'root',
          :require  => 'Class[Aptly]',
      })
    }

    context 'custom user' do
      let(:pre_condition)  { <<-EOS
        class { 'aptly':
          user => 'custom_user',
        }
        EOS
      }

      let(:params){{
        :component => 'third-party',
      }}

      it {
          should contain_exec('aptly_repo_create-example').with({
            :command  => /aptly repo create -component="third-party" example$/,
            :unless   => /aptly repo show example >\/dev\/null$/,
            :user     => 'custom_user',
            :require  => 'Class[Aptly]',
        })
      }
    end
  end
end
