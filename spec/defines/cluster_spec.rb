require 'spec_helper'

describe 'openondemand::cluster' do
  on_supported_os({
    :supported_os => [
      {
        "operatingsystem" => "RedHat",
        "operatingsystemrelease" => ["6"],
      }
    ]
  }).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let :title do
        'test'
      end

      let :params do
        {
          :acls => [
            {
              'adapter' => 'group',
              'groups' => ['test-group'],
              'type' => 'whitelist',
            }
          ],
          :rsv_query_acls => [
            {
              'adapter' => 'group',
              'groups' => ['test-group-rsv'],
              'type' => 'blacklist',
            }
          ],
          :login_server => 'login.test',
          :resource_mgr_host => 'batch.test',
          :resource_mgr_lib => '/opt/torque/lib64',
          :resource_mgr_bin => '/opt/torque/bin',
          :resource_mgr_version => '6.0.2',
          :scheduler_host => 'batch.test',
          :scheduler_bin => '/opt/moab/bin',
          :scheduler_version => '9.0.1',
          :scheduler_params => {
            'moabhomedir' => '/var/spool/moab',
          },
          :ganglia_host => 'ganglia.test',
        }
      end

      it do
        should contain_file('/etc/ood/config/clusters.d/test.yml').with({
          'ensure'  => 'file',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      end

      it do
        content = catalogue.resource('file', '/etc/ood/config/clusters.d/test.yml').send(:parameters)[:content]
        puts content
      end

    end
  end
end

