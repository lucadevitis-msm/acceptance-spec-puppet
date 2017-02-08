# rubocop:disable Metrics/LineLength
# rubocop:disable Metrics/BlockLength
require 'serverspec'
require 'json'

if RUBY_PLATFORM =~ /cygwin|mswin|mingw|bccwin|wince|emx/
  set :backend, :cmd
  set :os, family: 'windows'
else
  set :backend, :exec
end

full_module_name = JSON.parse(File.read('metadata.json'))['name']

module_name = full_module_name.split('-').last

describe "Puppet module \"#{full_module_name}\"" do
  describe file('metadata.json') do
    it { is_expected.to be_file }
    describe 'metadata' do
      subject { described_class.content_as_json }
      github = 'https://github.com/MSMFG'
      # should include "version" matching sematic versioning
      it { is_expected.to include('version' => match(/^[0-9]+(\.[0-9]+){0,2}$/)) }
      # should include "author" matching MoneySupermarket.com email
      it { is_expected.to include('author' => match(/at moneysupermarket\.com/)) }
      # should be an MSMFG hosted module
      it { is_expected.to include('source' => match(%r{#{github}/#{full_module_name}})) }
      it { is_expected.to include('project_page' => match(%r{#{github}/#{full_module_name}})) }
      it { is_expected.to include('issues_url' => match(%r{#{github}/#{full_module_name}/issues})) }
    end
  end

  describe file('manifests/init.pp') do
    it { is_expected.to be_file }
    its(:content) { is_expected.to contain(/class #{module_name}/) }
  end

  describe 'Directory "specs"' do
    subject { Dir['spec/{classes,defines,functions,acceptance}/**/*_spec.rb'] }
    it { is_expected.not_to be_empty }
    it 'should include at least 1 class spec' do
      is_expected.to include(match(%r{^spec/classes/}))
    end
    it 'should include at least 1 acceptance spec' do
      is_expected.to include(match(%r{^spec/acceptance/}))
    end
  end

  describe file('.fixtures.yaml') do
    it { is_expected.to be_file }
    describe 'fixtures' do
      subject { described_class.content_as_yaml }
      it 'should define a symlink to source_dir' do
        is_expected.to include('fixtures' => include('symlinks' => { module_name => '#{source_dir}' }))
      end
    end
  end

  describe file('spec/acceptance/nodesets/default.yml') do
    it { is_expected.to be_file }
    describe 'nodeset' do
      subject { described_class.content_as_yaml }
      it 'should configure a masterless environment' do
        is_expected.to include('CONFIG' => include('masterless' => true))
      end

      it 'should include a default host' do
        is_expected.to include('HOSTS' => include('default'))
      end
    end
  end

  describe file('Gemfile') do
    it { is_expected.to be_file }
    its(:content) { is_expected.to contain(/gem .msmfg_spec_helper./) }
  end

  describe file('Gemfile.lock') do
    it { is_expected.to be_file }
  end

  describe file('Rakefile') do
    it { is_expected.to be_file }
    it { is_expected.to contain(%r{require .msmfg_spec_helper/rake_tasks/puppet_module.}) }
  end
end
