# rubocop:disable Metrics/LineLength
require 'serverspec'

set :backend, :exec

module_name = JSON.load(File.read('metadata.json'))['name'].split('-').last

describe "MSMFG puppet module #{module_name}" do
  describe file("metadata.json") do
    it { is_expected.to be_file }
    describe 'metadata' do
      subject { described_class.content_as_json }
      # it { is_expected.to include('name', 'summary', 'source', 'license') }
      it 'should include "version" matching sematic versioning' do
        is_expected.to include('version' => match(/^[0-9]+(\.[0-9]+){0,2}$/))
      end
      it 'should include "author" matching MoneySupermarket.com email' do
        is_expected.to include('author' => match(/at moneysupermarket\.com/))
      end
    end
  end
  
  describe file("manifests/init.pp") do
    it { is_expected.to be_file }
    its(:content) { is_expected.to contain("class #{module_name}") }
  end
  
  describe 'specs' do
    subject { Dir['spec/{classes,defines,functions,acceptance}/**/*_spec.rb'] }
    it { is_expected.not_to be_empty }
    it 'should include at least 1 class spec' do
      is_expected.to include(match(%r{^spec/classes/}))
    end
    it 'should include at least 1 acceptance spec' do
      is_expected.to include(match(%r{^spec/acceptance/}))
    end
  end
  
  describe file(".fixtures.yaml") do
    it { is_expected.to be_file }
    describe 'fixtures' do
      subject { described_class.content_as_yaml }
      it 'should define a symlink to source_dir' do
        is_expected.to include('fixtures' => include('symlinks' => { module_name => '#{source_dir}' }))
      end
    end
  end
  
  describe file("spec/acceptance/nodesets/default.yml") do
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
  
  describe file("Gemfile") do
    it { is_expected.to be_file }
    describe 'content' do
      # This should be replaced by the current gem
      development_gems = ['bundler', 'rake',
                          'wirble', 'pry',
                          'puppet-strings', "puppet', '< 4", 'hiera']
      test_gems = ['metadata-json-lint', 'rubocop',
                   'puppetlabs_spec_helper', 'hiera-puppet-helper',
                   'coveralls']
      acceptance_gems = ['beaker-facter', 'beaker-hiera', 'beaker-rspec']
  
      subject { described_class.content }
      it { is_expected.to contain('gemspec').before(/^source/) }
      (development_gems + test_gems + acceptance_gems).each do |bundled_gem|
        it { is_expected.to contain("gem '#{bundled_gem}'").after(/^source/) }
      end
    end
  end
  describe file("Gemfile.lock") do
    it { is_expected.to be_file }
  end
  describe file("Rakefile") do
    it { is_expected.to be_file }
    [
      'bundler/gem_tasks',                  # Creates `:build` task
      'puppetlabs_spec_helper/rake_tasks',  # Creates other default tasks
      'puppet-strings/tasks',               # Creates `strings` class
      'rake/clean'                          # Creates `:clean` and `:clobber`
    ].each do |filename|
      it { is_expected.to contain("require '#{filename}'") }
    end
  end
end
