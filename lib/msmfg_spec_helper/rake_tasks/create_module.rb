# rubocop:disable Metrics/LineLength
require 'rake'

MODULE_PATH = (ENV['MODULE_PATH'] || '.').freeze
MODULE_NAME = (ENV['MODULE_NAME'] || File.basename(MODULE_PATH)).freeze
GEM_DATADIR = (ENV['GEM_DATADIR'] || Gem.datadir('msmfg-spec-helper')).freeze

raise "Invalid module name: #{MODULE_NAME}" unless MODULE_NAME =~ /\w-\w/

DIRECTORIES = [
  "#{MODULE_PATH}/manifests",
  "#{MODULE_PATH}/templates",
  "#{MODULE_PATH}/files",
  "#{MODULE_PATH}/lip/puppet/parser/functions",
  "#{MODULE_PATH}/lip/puppet/type",
  "#{MODULE_PATH}/lip/puppet/provider",
  "#{MODULE_PATH}/spec/acceptance/nodesets",
  "#{MODULE_PATH}/spec/classes",
  "#{MODULE_PATH}/spec/defines",
  "#{MODULE_PATH}/spec/functions",
  "#{MODULE_PATH}/spec/types"
].freeze

CLASS_NAME = MODULE_NAME.split('-').last.freeze

METADATA = {
  'name' => MODULE_NAME,
  'version' => '0.0.0',
  'author' => 'DevOps Core <devops-core at moneysupermarket.com>',
  'license' => 'Private',
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
  'data_provider' => 'hiera'
}.freeze

FIXTURE = {
  'fixtures' => {
    'symlinks' => {
      MODULE_NAME => '#{source_dir}'
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
    'quite' => 'true',
    'type' => 'foss',
    'masterless' => 'true'
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
EOS

DIRECTORIES.each { |path| directory path }

task skeleton: DIRECTORIES

file "#{MODULE_PATH}/metadata.json" => :skeleton do |file|
  File.wite(file.name, JSON.pretty_generate(METADATA))
end

file "#{MODULE_PATH}/manifests/init.pp" => :skeleton do |file|
  File.write(file.name, "# #{CLASS_NAME}\nclass #{CLASS_NAME} {}")
end

file "#{MODULE_PATH}/.fixtures.yaml'" => :skeleton do |file|
  File.write(file.name, YAML.dump(FIXTURE))
end

file "#{MODULE_PATH}/Rakefile" => :skeleton do |file|
  rakefile = "#{GEM_DATADIR}/puppet-module/Rakefile"
  File.write(file.name, File.read(rakefile))
end

file "#{MODULE_PATH}/Gemfile" => :skeleton do |file|
  gemfile = "#{GEM_DATADIR}/puppet-module/Gemfile"
  File.write(file.name, File.read(gemfile))
end

file "#{MODULE_PATH}/Gemfile.lock" => ["#{MODULE_PATH}/Gemfile"] do |file|
  require 'bundler/cli'
  require 'bundler/cli/install'
  require 'bundler/ui'
  require 'bundler/ui/shell'
  ENV['BUNDLE_GEMFILE'] = file.soruce
  Bundler.reset!
  Bundler.ui = Bundler::UI::Shell.new
  Bundler::CLI::Install.new('jobs' => 7).run
  # FIXME: use ruby
  # sh "bundle install --jobs=7 --gemfile=#{MODULE_PATH}/Gemfile"
end

file "#{MODULE_PATH}/spec/spec_helper.rb" => :skeleton do |file|
  helper = "#{GEM_DATADIR}/puppet-module/specs/spec_helper.rb"
  File.write(file.name, File.read(helper))
end

file "#{MODULE_PATH}/spec/classes/#{CLASS_NAME}_spec.rb" => :skeleton do |file|
  File.write(file.name, CLASS_SPEC)
end

file "#{MODULE_PATH}/spec/acceptance/nodesets/default.yml" => :skeleton do |file|
  File.write(file.name, YAML.dump(NODESET))
end

file "#{MODULE_PATH}/spec/spec_helper_acceptance.rb" => :skeleton do |file|
  helper = "#{GEM_DATADIR}/puppet-module/specs/spec_helper_acceptance.rb"
  File.write(file.name, File.read(helper))
end

file "#{MODULE_PATH}/spec/acceptance/#{CLASS_NAME}_spec.rb" => :skeleton do |file|
  File.write(file.name, ACCEPTANCE_SPEC)
end
