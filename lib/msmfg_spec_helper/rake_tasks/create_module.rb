# rubocop:disable Metrics/LineLength
require 'json'
require 'rake'
require 'yaml'

MODULE_NAME = (ENV['MODULE_NAME'] || 'msmfg-skeleton').freeze
raise "Invalid module name: #{MODULE_NAME}" unless MODULE_NAME =~ /\w-\w/

DIRECTORIES = [
  'manifests',
  'templates',
  'files',
  'lib/puppet/parser/functions',
  'lib/puppet/type',
  'lib/puppet/provider',
  'spec/acceptance/nodesets',
  'spec/classes',
  'spec/defines',
  'spec/functions',
  'spec/types'
].freeze

CLASS_NAME = MODULE_NAME.split('-').last.freeze

METADATA = {
  'name' => MODULE_NAME,
  'version' => '0.0.0',
  'author' => 'DevOps Core <devops-core at moneysupermarket.com>',
  'license' => 'proprietary',
  'summary' => '<replace_me>',
  'source' => "https://github.com/MSMFG/#{MODULE_NAME}",
  'project_page' => "https://github.com/MSMFG/#{MODULE_NAME}",
  'issues_url' => "https://github.com/MSMFG/#{MODULE_NAME}/issues",
  'tags' => ['<replace_me>'],
  'operatingsystem_support' => [
    {
      'operatingsystem' => 'CentOS',
      'operatingsystemrelease' => ['5.0', '6.0', '7.0']
    }
  ],
  'dependencies' => [],
  'data_provider' => 'hiera'
}.freeze

FIXTURE = {
  'fixtures' => {
    'symlinks' => {
      CLASS_NAME => '#{source_dir}'
    }
  }
}.freeze

NODESET = {
  'HOSTS' => {
    'default' => {
      'platform' => 'el-6-x86_64',
      'image' => 'centos:6.6-msm',
      'hypervisor' => 'docker',
      'docker_container_name' => 'centos6.6-msm'
    }
  },
  'CONFIG' => {
    'log_level' => 'warn',
    'quite' => true,
    'type' => 'foss',
    'masterless' => true
  }
}.freeze

CLASS_SPEC = <<EOS.freeze
require 'spec_helper'

describe '#{CLASS_NAME}' do
  it { is_expected.to compile }
end
EOS

ACCEPTANCE_SPEC = <<EOS.freeze
require 'spec_helper_acceptance'

describe '#{CLASS_NAME} class' do
  let(:pp) do
    <<-MANIFEST
      class { '#{CLASS_NAME}':
      }
    MANIFEST
  end

  describe 'puppet apply manifest' do
    subject { apply_manifest pp, catch_failures: true }

    it 'should run without errors' do
      expect(subject.exit_code).to eq 2
    end

    it 'should run a second time without changes' do
      expect(subject.exit_code).to eq 0
    end
  end
end
EOS

DIRECTORIES.each do |path|
  desc "Creates #{path}"
  directory path
end

task skeleton: DIRECTORIES

desc 'Creates metadata.json'
file 'metadata.json' => :skeleton do |file|
  File.write(file.name, JSON.pretty_generate(METADATA))
end

desc 'Creates manifests/init.pp'
file 'manifests/init.pp' => :skeleton do |file|
  File.write(file.name, "# #{CLASS_NAME}\nclass #{CLASS_NAME} {}\n")
end

desc 'Creates .fixtures.yaml'
file '.fixtures.yaml' => :skeleton do |file|
  File.write(file.name, YAML.dump(FIXTURE))
end

desc 'Creates Rakefile'
file 'Rakefile' => :skeleton do |file|
  File.write(file.name, "require 'msmfg_spec_helper/rake_tasks/module'\n")
end

desc 'Creates Gemfile'
file 'Gemfile' => :skeleton do |file|
  File.write(file.name, "gem 'msmfg-spec-helper'\n")
end

desc 'Creates Gemfile.lock'
file 'Gemfile.lock' => ['Gemfile'] do |file|
  require 'bundler/cli'
  require 'bundler/cli/install'
  require 'bundler/ui'
  require 'bundler/ui/shell'
  ENV['BUNDLE_GEMFILE'] = file.source
  Bundler.reset!
  Bundler.ui = Bundler::UI::Shell.new
  Bundler::CLI::Install.new('jobs' => 7).run
end

desc 'Creates spec/spec_helper.rb'
file 'spec/spec_helper.rb' => :skeleton do |file|
  File.write(file.name, "require 'msmfg_spec_helper/spec_helper'\n")
end

desc "Creates spec/classes/#{CLASS_NAME}_spec.rb"
file "spec/classes/#{CLASS_NAME}_spec.rb" => :skeleton do |file|
  File.write(file.name, CLASS_SPEC)
end

desc 'Creates spec/acceptance/nodesets/default.yml'
file 'spec/acceptance/nodesets/default.yml' => :skeleton do |file|
  File.write(file.name, YAML.dump(NODESET))
end

desc 'Creates spec/spec_helper_acceptance.rb'
file 'spec/spec_helper_acceptance.rb' => :skeleton do |file|
  File.write(file.name, "require 'msmfg_spec_helper/spec_helper_acceptance.rb'\n")
end

desc "Creates spec/acceptance/#{CLASS_NAME}_spec.rb"
file "spec/acceptance/#{CLASS_NAME}_spec.rb" => :skeleton do |file|
  File.write(file.name, ACCEPTANCE_SPEC)
end

desc "Creates module '#{MODULE_NAME}' skeleton"
task create_module: ['metadata.json',
                     'manifests/init.pp',
                     '.fixtures.yaml',
                     'Rakefile',
                     'Gemfile',
                     'Gemfile.lock',
                     'spec/spec_helper.rb',
                     "spec/classes/#{CLASS_NAME}_spec.rb",
                     'spec/acceptance/nodesets/default.yml',
                     'spec/spec_helper_acceptance.rb',
                     "spec/acceptance/#{CLASS_NAME}_spec.rb"]
