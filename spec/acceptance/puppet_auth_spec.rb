# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'puppet_auth' do
  before(:all) do
    shell("printf 'path /report\\nmethod save\\nallow *\\n\\npath /\\nauth any\\n' > /tmp/auth_test.conf")
  end

  context 'with ensure => present' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PUPPET
          puppet_auth { 'Allow /facts before first denied rule':
            ensure        => present,
            path          => '/facts',
            authenticated => 'any',
            allow         => '*',
            methods       => ['find', 'search'],
            ins_before    => 'first deny',
            target        => '/tmp/auth_test.conf',
          }
          # authenticated is set because saving a new rule without it fails with Augeas 1.15
          puppet_auth { 'Allow own catalog':
            ensure        => present,
            path          => '^/catalog/([^/]+)$',
            path_regex    => true,
            allow         => '$1',
            authenticated => 'any',
            ins_before    => 'first deny',
            target        => '/tmp/auth_test.conf',
          }
        PUPPET
      end
    end

    describe file('/tmp/auth_test.conf') do
      its(:content) { is_expected.to match(%r{^path /report\nmethod save\nallow \*$}) }
      its(:content) { is_expected.to match(%r{^path /facts\n(.+\n)*method find, ?search$}) }
      its(:content) { is_expected.to match(%r{^path ~ \^/catalog/\(\[\^/\]\+\)\$\nallow \$1\nauth any$}) }
      its(:content) { is_expected.to match(%r{path /facts(.*\n)+path /\n}) }
    end
  end

  context 'with ensure => absent' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PUPPET
          puppet_auth { 'Remove /report':
            ensure => absent,
            path   => '/report',
            target => '/tmp/auth_test.conf',
          }
        PUPPET
      end
    end

    describe file('/tmp/auth_test.conf') do
      its(:content) { is_expected.not_to match(%r{/report}) }
      its(:content) { is_expected.to match(%r{^path /facts$}) }
    end
  end
end
