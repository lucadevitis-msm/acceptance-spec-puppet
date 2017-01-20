# rubocop:disable Metrics/LineLength
require 'serverspec'

module_path = ENV['MODULE_PATH']
module_name = ENV['MODULE_NAME'] || ::File.basename(module_path.to_s).split('-').last

Dir.chdir(module_path)

describe "puppet module #{module_name}" do
  set :backend, :exec

  describe file('metadata.json') do
    it { is_expected.to be_file }
    describe 'metadata' do
      subject { described_class.content_as_json }
      it { is_expected.to include('summary', 'source', 'license') }
      it 'should include "name" matching module_name' do
        is_expected.to include('name' => match(/#{module_name}/))
      end
      it 'should include "version" matching sematic versioning' do
        is_expected.to include('version' => match(/^[0-9]+(\.[0-9]+){0,2}$/))
      end
      it 'should include "author" matching MoneySupermarket.com email' do
        is_expected.to include('author' => match(/at moneysupermarket\.com/))
      end
      it 'should include "tag" and that should include module_name' do
        is_expected.to include('tags' => include(module_name))
      end
    end
  end
  describe file('manifests/init.pp') do
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
    describe 'content' do
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
  describe file('Gemfile.lock') do
    it { is_expected.to be_file }
  end
  describe file('Rakefile') do
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
