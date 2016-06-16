require 'spec_helper'

describe 'openondemand' do
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
        facts.merge({
          :concat_basedir => '/dne',
        })
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to create_class('openondemand') }
      it { is_expected.to contain_class('openondemand::params') }

      #it { is_expected.to contain_anchor('openondemand::start').that_comes_before('Class[openondemand::install]') }
      #it { is_expected.to contain_class('openondemand::install').that_comes_before('Class[openondemand::config]') }
      #it { is_expected.to contain_class('openondemand::config').that_notifies('Class[openondemand::service]') }
      #it { is_expected.to contain_class('openondemand::service').that_comes_before('Anchor[openondemand::end]') }
      #it { is_expected.to contain_anchor('openondemand::end') }

      #include_context 'openondemand::install'
      #include_context 'openondemand::config'
      #include_context 'openondemand::service'

      # Test validate_bool parameters
      [

      ].each do |param|
        context "with #{param} => 'foo'" do
          let(:params) {{ param.to_sym => 'foo' }}
          it 'should raise an error' do
            expect { is_expected.to compile }.to raise_error(/is not a boolean/)
          end
        end
      end

    end # end context
  end # end on_supported_os loop
end # end describe
