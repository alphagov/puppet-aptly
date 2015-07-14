require 'spec_helper'

describe 'aptly::snapshot' do
  let(:title) { 'example' }

  let(:facts){{
    :lsbdistid => 'ubuntu',
  }}

  describe 'param defaults' do
    it {
        should contain_exec('aptly_snapshot_create-example').with({
          :command  => /aptly -config \/etc\/aptly.conf snapshot create example empty$/,
          :unless   => /aptly -config \/etc\/aptly.conf snapshot show example >\/dev\/null$/,
          :user     => 'root',
          :require  => 'Class[Aptly]',
      })
    }
  end

  describe 'user defined params' do
    context 'passing both params' do
      let(:params){{
        :repo   => 'example_repo',
        :mirror => 'example_mirror',
      }}

      it {
        should raise_error(Puppet::Error, /mutually exclusive/)
      }
    end

    context 'passing repo param' do
      let(:params){{
        :repo   => 'example_repo',
      }}

      it {
          should contain_exec('aptly_snapshot_create-example').with({
            :command  => /aptly -config \/etc\/aptly.conf snapshot create example from repo example_repo$/,
            :unless   => /aptly -config \/etc\/aptly.conf snapshot show example >\/dev\/null$/,
            :user     => 'root',
            :require  => 'Class[Aptly]',
        })
      }
    end

    context 'passing mirror param' do
      let(:params){{
        :mirror   => 'example_mirror',
      }}

      it {
          should contain_exec('aptly_snapshot_create-example').with({
            :command  => /aptly -config \/etc\/aptly.conf snapshot create example from mirror example_mirror$/,
            :unless   => /aptly -config \/etc\/aptly.conf snapshot show example >\/dev\/null$/,
            :user     => 'root',
            :require  => 'Class[Aptly]',
        })
      }
    end

  end
end
