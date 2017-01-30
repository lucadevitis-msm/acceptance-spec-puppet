require 'rake'

MODULE_PATH = (ENV['MODULE_PATH'] || '.').freeze
MODULE_NAME = (ENV['MODULE_NAME'] || ::File.basename(MODULE_PATH)).freeze

raise "Invalid module name: #{MODULE_NAME}" unless (MODULE_NAME =~ /\w-\w/)

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
  "#{MODULE_PATH}/spec/types"].freeze

CLASS_NAME = MODULE_NAME.split('-').last.freeze

METADATA = {
  'name' => MODULE_NAME,
  'version' => '0.0.0',
  'author' => 'DevOps Core <devops-core at moneysupermarket.com>',
  'license' => 'MIT',
  'summary' => '<replace_me>',
  'source' => "https://github.com/MSMFG/#{MODULE_NAME}",
  'project_page' => "https://github.com/MSMFG/#{MODULE_NAME}",
  'issues_url' => "https://github.com/MSMFG/#{MODULE_NAME}/issues",
  'tags' => [ '<replace_me>' ],
  'operatingsystem_support' => [
    {
      'operatingsystem' => 'CentOS',
      'operatingsystemrelease' => [ '5.0', '6.0', '7.0' ]
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

GEMFILE = <<EOF
gemspec
source 'https://rubygems.org' do
  group :docs do
    gem 'puppet-strings'
  end

  group :development do
    gem 'bundler', '~> 1.11'
    gem 'coveralls'
    gem 'hiera'
    gem 'hiera-puppet-helper'
    gem 'metadata-json-lint'
    gem 'pry'
    gem 'puppet', '< 4'
    gem 'puppetlabs_spec_helper'
    gem 'rake', '~> 10.0'
    gem 'rubocop'
    gem 'ruby-augeas'
    gem 'safe_yaml'
    gem 'serverspec'
    gem 'wirble'
  end

  group :acceptance do
    gem 'beaker'
    gem 'beaker-facter'
    gem 'beaker-hiera'
    gem 'beaker-rspec'
    gem 'minitest'
  end
end
EOF

NODESET = {
  'HOSTS' => {
    'default' => {
      'platform' => 'el-6-x86_64',
      'image' => 'centos:6.6-msm',
      'hypervisor' => 'docker',
      'docker_container_name' => 'centos6.6-msm'
    }
  }
  'CONFIG' => {
    'log_level' => 'warn',
    'quite' => 'true',
    'type' => 'foss',
    'masterless' => 'true'
  }
}

DIRECTORIES.each { |path| directory path }

task :skeleton => DIRECTORIES

file "#{MODULE_PATH}/metadata.json" => :skeleton do |file|
  ::File.wite(file.name, JSON.pretty_generate(METADATA))
end

file "#{MODULE_PATH}/manifests/init.pp" => :skeleton do |file|
  ::File.write(file.name, "# #{CLASS_NAME}\nclass #{CLASS_NAME} {}")
end

file "#{MODULE_PATH}/.fixtures.yaml'" => :skeleton do |file|
  ::File.write(file.name, YAML.dump(FIXTURE))
end

file "#{MODULE_PATH}/Gemfile" => :skeleton do |file|
  ::File.write(file.name, GEMFILE)
end

file "#{MODULE_PATH}/Gemfile.lock" => ["#{MODULE_PATH}/Gemfile"] do |file|
  # FIXME: use ruby
  sh "bundle install --jobs=7 --gemfile=#{MODULE_PATH}/Gemfile"
end

file "#{MODULE_NAME}/acceptance/nodesets/default.yml" => :skeleton do |file|
  ::File.write(file.name, YAML.dump(NODESET))
end
