require 'spec_helper'

describe 'openondemand::app::usr' do
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
        {}
      end

      it do
        should contain_file('/var/www/ood/apps/usr/test').with({
          'ensure'  => 'directory',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0750',
        })
      end

      it do
        is_expected.to contain_exec('openondemand::app::usr-link-gateway-test').with({
            :path       => '/usr/bin:/bin:/usr/sbin:/sbin',
            :command    => 'ln -s ~test/ood/share /var/www/ood/apps/usr/test/gateway',
            :unless     => 'test -L /var/www/ood/apps/usr/test/gateway',
            :require    => 'File[/var/www/ood/apps/usr/test]',
        })
      end

    end
  end
end

