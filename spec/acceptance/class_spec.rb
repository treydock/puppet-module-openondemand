require 'spec_helper_acceptance'

describe 'openondemand class:' do
  context 'default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
      package { 'centos-release-scl': }->
      class { 'openondemand': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/etc/ood/config/clusters.d/test.yml') do
      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      its(:content) { should match // }
    end
  end
end
