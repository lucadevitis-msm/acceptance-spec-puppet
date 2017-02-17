# rubocop:disable Metrics/LineLength
require 'github_api'
require 'json'
require 'msmfg_spec_helper/version'
require 'msmfg_spec_helper/logger'
require 'puppet_forge'
require 'yaml'

module MSMFGSpecHelper
  # rubocop:disable Metrics/ClassLength

  # MSMFG puppet module class.
  # This class is mainly used to create the module's files.
  class PuppetModule
    include MSMFGSpecHelper::LoggerMixIn

    # Modulefile DSL parser
    # @api private
    class Modulefile
      class << self
        include MSMFGSpecHelper::LoggerMixIn

        # `Modulefile` metadata and respective defaults
        METADATA = {
          name: nil,
          version: nil,
          summary: nil,
          description: nil,
          project_page: nil,
          license: nil,
          author: nil,
          source: nil,
          dependencies: []
        }.freeze

        # Easy access to the list of dependencies
        #
        # @return [Array]
        #   list of dependencies
        attr_accessor :dependencies

        # Automatically generates DSL methods for the `Modulefile`
        METADATA.keys.reject { |m| m == :dependencies }.each do |name|
          define_method(name) do |value = nil|
            if value
              logger.debug("Modulefile: #{name}: #{value}")
              instance_variable_set("@#{name}", value)
            end
            instance_variable_get("@#{name}")
          end
        end

        # DSL method for `dependency` must be handled separatly
        #
        # @param [Array<String>] args
        #   dependency attributes
        #
        # @return [Array]
        #   added dependency
        #
        # @api private
        def dependency(*args)
          logger.debug("Modulefile: dependency: #{args.join(', ')}")
          @dependencies << args
          args
        end

        # Read Modulefile
        #
        # @param [String] modulefile
        #   path to the Modulefile
        #
        # @return nil
        #
        # @api private
        def read(modulefile = 'Modulefile')
          METADATA.each { |k, v| instance_variable_set("@#{k}", v) }
          # This is unsecure, but:
          #
          # - This class should not be used outside of this context
          # - This class is not meant to deal malicious configurations
          # - Modulefile content should have already been reviewed by members
          #   of the staff
          logger.debug("Modulefile: reading #{modulefile}")
          instance_eval File.read(modulefile)
          logger.info("Modulefile: #{modulefile} loaded succefully")
        rescue Errno::ENOENT
          logger.info("Modulefile: #{modulefile} not found")
        end
      end
    end

    # Returns metadata.json content or {}
    #
    # @param [String] path
    #   metadata.json full path
    #
    # @return [Hash]
    #   content of metadata.json
    #
    # @api private
    def metadata_json(path = 'metadata.json')
      if @metadata_json.nil?
        logger.debug("metadata_json: reading #{path}")
        @metadata_json ||= JSON.parse(File.read(path))
        logger.info("metadata_json: #{path} loaded succefully")
      end
      @metadata_json
    rescue Errno::ENOENT
      logger.info("metadata_json: #{path} not found")
      @metadata_json = {}
    end

    # What an MSMFG puppet module should look like on the filesystem
    #
    # If not specified, module's name is guessed from `Modulefile` and then
    # `metadata.json`, if available. If not, for example you are creating a new
    # module, module's name is taken from environment variable `MODULE_NAME`.
    # If environment variable is not present, module's name is taken from
    # current working directory.
    #
    # @example
    #   puppet_module = MSMFGSpecHelper::PuppetModule.new
    #
    # @param [String] name
    #   The name of the puppet module.
    #
    # @api public
    def initialize(name = nil)
      @name = name ||
              Modulefile.name ||
              metadata_json['name'] ||
              ENV['MODULE_NAME'] ||
              File.basename(Dir.pwd)
      logger.debug("PuppetModule: name set to #{@name}")

      PuppetForge.user_agent = "msmfg_spec_helper/#{MSMFGSpecHelper::VERSION}"
      PuppetForge.host = ENV['PUPPETFORGE_ENDPOINT'] if ENV['PUPPETFORGE_ENDPOINT']
      logger.debug("PuppetModule: PuppetForge host set to #{PuppetForge.host}")

      Github.configure do |conf|
        conf.basic_auth = "#{ENV['GITHUB_USER']}:#{ENV['GITHUB_PASSWORD']}"
        logger.debug("PuppetModule: Github basic_auth set to #{ENV['GITHUB_USER']}:i_did_not_start_yesterday")

        conf.endpoint = ENV['GITHUB_ENDPOINT'] if ENV['GITHUB_ENDPOINT']
        logger.debug("PuppetModule: GitHub endpoint set to #{conf.endpoint}")

        conf.site = "https://#{ENV['GITHUB_FQDN']}" if ENV['GITHUB_FQDN']
        logger.debug("PuppetModule: GitHub site set to #{conf.site}")
      end

      Modulefile.read
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
      if @metadata.nil?
        default_author = 'DevOps Core <devops-core at moneysupermarket.com>'

        logger.debug('PuppetModule: metadata: calculating dependencies ...')
        dependencies = Modulefile.dependencies.reject do |name, _|
          # We can't list msmfg puppet modules as dependency (yet)
          name =~ %r{^MSMFG/puppet-}
        end
        dependencies.collect! do |name, requirement, _|
          { 'name' => name, 'version_requirement' => requirement }
        end

        logger.debug('PuppetModule: metadata: generating metadata ...')
        @metadata = {
          'name' => name,
          'version' => Modulefile.version || '0.0.0',
          'author' => Modulefile.author || default_author,
          'license' => 'proprietary',
          'summary' => Modulefile.summary.to_s,
          'source' => "https://github.com/MSMFG/#{name}/",
          'issues_url' => "https://github.com/MSMFG/#{name}/issues",
          'project_page' => "https://msmfg.github.io/#{name}/",
          'operatingsystem_support' => [
            {
              'operatingsystem' => 'CentOS',
              'operatingsystemrelease' => ['5.0', '6.0', '7.0']
            }
          ],
          'data_provider' => 'hiera',
          'dependencies' => dependencies
        }.freeze
      end
      @metadata
    end

    # Return the module's initial fixtures configuration
    #
    # @return [Hash]
    #   the module's fixtures configuration
    #
    # @api private
    def fixtures
      if @fixtures.nil?
        forge_modules = {}
        repositories = {}

        Modulefile.dependencies.each do |name, requirement|
          logger.debug("PuppetModule: fixtures: looking for #{name} #{requirement}")

          provider_name, module_name = name.split('/')

          if provider_name == 'MSMFG'
            candidate = find_repository(module_name, requirement)
            logger.debug("PuppetModule: fixtures: using #{candidate.inspect}")
            module_name.sub!(/^puppet-/, '')
            repositories[module_name] = candidate if candidate
          else
            candidate = find_forge_module(name, requirement)
            logger.debug("PuppetModule: fixtures: using #{candidate.inspect}")
            forge_modules[module_name] = candidate if candidate
          end
        end

        logger.debug('PuppetModule: fixtures: generating fixtures ...')
        @fixtures = {
          'fixtures' => {
            'symlinks' => {
              class_name => '#{source_dir}'
            }
          }
        }
        @fixtures['repositories'] = repositories if repositories.any?
        @fixtures['forge_modules'] = forge_modules if forge_modules.any?
        @fixtures.freeze
      end
      @fixtures
    end

    # Looks for the latest repository release, matching requirements
    #
    # @param [String] module_name
    #   the puppet module name (repo name)
    #
    # @param [String] requirement
    #   the version requirement specification
    #
    # @return [Hash]
    #   repository info, or `nil`
    #
    # @api private
    def find_repository(module_name, requirement)
      # Let's query GitHub
      releases = Github::Client::Repos::Releases.new

      # The following assumes that we use version strings as GitHub releases
      candidates = releases.list('MSMFG', module_name).select do |release|
        Gem::Version.correct?(release.tag_name) &&
          Gem::Dependency.new('', requirement).match?('', release.tag_name)
      end

      repo = "#{Github.configuration.site}/MSMFG/#{module_name}.git"
      ref = candidates.collect { |r| Gem::Version.new(r.tag_name) }.sort.last.to_s
      ref && { 'repo' => repo, 'ref' => ref }
    end

    private :find_repository

    # Looks for the latest puppet forge module, matching requirements
    #
    # @param [String] name
    #   the full module name
    #
    # @param [String] requirement
    #   the version requirement specification
    #
    # @return [Hash]
    #   puppet forge module info, or `nil`
    #
    # @api private
    def find_forge_module(name, requirement)
      # Let's query the PuppetForge
      releases = PuppetForge::Module.find(name.tr('/', '-')).releases

      candidates = releases.select do |release|
        Gem::Version.correct?(release.version) &&
          Gem::Dependency.new('', requirement).match?('', release.version)
      end

      ref = candidates.map { |r| Gem::Version.new(r.version) }.sort.last.to_s
      ref && { 'repo' => name, 'ref' => ref }
    end

    private :find_forge_module

    # Returns `beaker`'s default configuration
    #
    # @return [Hash]
    #   the module's default nodeset configuration
    #
    # @api private
    def nodeset
      logger.debug("PuppetModule: nodeset: generating beaker's nodeset ...")
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
      logger.debug('PuppetModule: class_spec: generating class specs ...')
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
      logger.debug('PuppetModule: acceptance_spec: generating acceptance specs ...')
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
        'lib/puppet/parser/functions',
        'lib/puppet/provider',
        'lib/puppet/type',
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
          name: '.fixtures.yml',
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
          name: 'spec/acceptance/nodesets/default.yml',
          create: proc do |file|
            File.write(file.name, YAML.dump(nodeset))
          end
        },
        {
          name: 'spec/spec_helper.rb',
          requires: ['spec/acceptance/nodesets/default.yml'],
          create: proc do |file|
            lib = 'msmfg_spec_helper/puppet_module/spec_helper'
            File.write(file.name, "require '#{lib}'\n")
          end
        },
        {
          name: 'spec/spec_helper_acceptance.rb',
          requires: ['spec/acceptance/nodesets/default.yml'],
          create: proc do |file|
            lib = 'msmfg_spec_helper/puppet_module/spec_helper_acceptance'
            File.write(file.name, "require '#{lib}'\n")
          end
        },
        {
          name: "spec/classes/#{class_name}_spec.rb",
          requires: ['spec/spec_helper.rb', '.fixtures.yml'],
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
