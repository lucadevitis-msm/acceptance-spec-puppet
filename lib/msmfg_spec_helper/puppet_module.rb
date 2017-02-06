require 'json'
require 'yaml'

module MSMFGSpecHelper
  # MSMFG puppet module class.
  # This class is mainly used to create the module's files.
  # rubocop:disable Metrics/ClassLength
  class PuppetModule
    # What an MSMFG puppet module should look like on the filesystem
    #
    # Module's name is guessed from `metadata.json`, if available. If not, for
    # example you are creating a new module, module's name it is taken from
    # environment variable `MODULE_NAME`. If environment variable is not
    # present, module's name is guessed from current working directory. As last
    # resort, you could set it as optional argument
    #
    # @example
    #   puppet_module = MSMFGSpecHelper::PuppetModule.new
    #
    # @param [String] name
    #   The name of the puppet module.
    #
    # @api public
    def initialize(name = nil)
      @name = name || JSON.parse(File.read('metadata.json'))['name']
    rescue
      @name = ENV['MODULE_NAME'] || File.basename(Dir.pwd)
    end

    # Returns the module name
    #
    # @return [String]
    #   the module name
    #
    # @api private
    attr_reader :name

    # Returns class name (or the module name without the provider prefix)
    #
    # @return [String]
    #   the module's main class name
    #
    # @api private
    def class_name
      name.split('-').last.freeze
    end

    # Returns module metadata
    #
    # @return [Hash]
    #   the module's metadata
    #
    # @api private
    def metadata
      {
        'name' => name,
        'version' => '0.0.0',
        'author' => 'DevOps Core <devops-core at moneysupermarket.com>',
        'license' => 'proprietary',
        'summary' => '<replace_me>',
        'source' => "https://github.com/MSMFG/#{name}",
        'project_page' => "https://github.com/MSMFG/#{name}",
        'issues_url' => "https://github.com/MSMFG/#{name}/issues",
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
    end

    # Return the module's initial fixtures configuration
    #
    # @return [Hash]
    #   the module's fixtures configuration
    #
    # @api private
    def fixtures
      {
        'fixtures' => {
          'symlinks' => {
            class_name => '#{source_dir}'
          }
        }
      }.freeze
    end

    # Returns `beaker`'s default configuration
    #
    # @return [Hash]
    #   the module's default nodeset configuration
    #
    # @api private
    def nodeset
      {
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
    end

    # Returns the base `rspec-puppet` spec content
    #
    # @return [String]
    #   the module's catalog specs
    #
    # @api private
    def class_spec
      <<EOS.freeze
require 'spec_helper'

# At least the manifest should compile.
describe '#{class_name}' do
  it { is_expected.to compile }
end
EOS
    end

    # Returns the base `rspec-puppet` acceptance spec content
    #
    # @return [String]
    #   the module's acceptance specs
    #
    # @api private
    def acceptance_spec
      <<EOS.freeze
require 'spec_helper_acceptance'

describe '#{class_name} class' do
  let(:pp) do
    <<-MANIFEST
      class { '#{class_name}':
        # You may want to put arguments here
      }
    MANIFEST
  end

  # `catch_failures: true` runs puppet with --detailed-exitcodes, so we expect
  # first run `exit_code` to be 2 and second to be 0. We want to run it twice,
  # because it's good practice to draft a manifest that can be applied multiple
  # times without any error.
  describe 'puppet apply manifest' do
    # This will run the block before each of the followng examples.
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
    end

    # Returns the module's list of directories (mainly used by rake tasks)
    #
    # @return [Array<String>]
    #   the module's directory structure
    #
    # @api private
    def directories
      [
        'manifests',
        'files',
        'templates',
        'lib',
        'lib/puppet',
        'lib/puppet/parser',
        'lib/puppet/parser/functions',
        'lib/puppet/provider',
        'lib/puppet/type',
        'spec',
        'spec/acceptance',
        'spec/acceptance/nodesets',
        'spec/classes',
        'spec/defines',
        'spec/functions',
        'spec/types'
      ].freeze
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength

    # Returns the list of rake tasks data needed to create the module's files
    #
    # @return [Array<Hash>]
    #   the module's file tasks data
    #
    # @api private
    def files
      [
        {
          name: 'metadata.json',
          create: proc do |file|
            File.write(file.name, JSON.pretty_generate(metadata))
          end
        },
        {
          name: 'manifests/init.pp',
          create: proc do |file|
            manifest = "# Initial #{class_name} documentation\n"
            manifest << "class #{class_name} {}\n"
            File.write(file.name, manifest)
          end
        },
        {
          name: '.fixtures.yaml',
          create: proc do |file|
            File.write(file.name, YAML.dump(fixtures))
          end
        },
        {
          name: 'Rakefile',
          create: proc do |file|
            lib = 'msmfg_spec_helper/rake_tasks/puppet_module'
            File.write(file.name, "require '#{lib}'\n")
          end
        },
        {
          name: 'Gemfile',
          create: proc do |file|
            gemfile = "source 'https://rubygems.org'\ngem 'msmfg_spec_helper'\n"
            File.write(file.name, gemfile)
          end
        },
        {
          name: 'Gemfile.lock',
          requires: ['Gemfile'],
          create: proc do |file|
            require 'bundler/cli'
            require 'bundler/cli/install'
            require 'bundler/ui'
            require 'bundler/ui/shell'
            ENV['BUNDLE_GEMFILE'] = file.source
            Bundler.reset!
            Bundler.ui = Bundler::UI::Shell.new
            Bundler::CLI::Install.new('jobs' => 7).run
          end
        },
        {
          name: 'spec/spec_helper.rb',
          create: proc do |file|
            lib = 'msmfg_spec_helper/puppet_module/spec_helper'
            File.write(file.name, "require '#{lib}'\n")
          end
        },
        {
          name: 'spec/acceptance/nodesets/default.yml',
          create: proc do |file|
            File.write(file.name, YAML.dump(nodeset))
          end
        },
        {
          name: 'spec/spec_helper_acceptance.rb',
          create: proc do |file|
            lib = 'msmfg_spec_helper/puppet_module/spec_helper_acceptance'
            File.write(file.name, "require '#{lib}'\n")
          end
        },
        {
          name: "spec/classes/#{class_name}_spec.rb",
          requires: ['spec/spec_helper.rb', '.fixtures.yaml'],
          create: proc do |file|
            File.write(file.name, class_spec)
          end
        },
        {
          name: "spec/acceptance/#{class_name}_spec.rb",
          requires: ['spec/spec_helper_acceptance.rb',
                     'spec/acceptance/nodesets/default.yml'],
          create: proc do |file|
            File.write(file.name, acceptance_spec)
          end
        }
      ]
    end
  end
end
