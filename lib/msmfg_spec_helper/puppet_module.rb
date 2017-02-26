# rubocop:disable Metrics/LineLength
require 'github_api'
require 'json'
require 'msmfg_spec_helper'
require 'msmfg_spec_helper/puppet_module/modulefile'
require 'puppet_forge'
require 'yaml'

module MSMFGSpecHelper
  # rubocop:disable Metrics/ModuleLength

  # MSMFG puppet module class.
  # This class is mainly used to create the module's files.
  module PuppetModule
    class << self
      include MSMFGSpecHelper::LoggerMixIn

      # Returns metadata.json content or generate one
      #
      # If `metadata.json` is not available, tries to use `Modulefile`. If
      # `Modulefile` is not available, uses deffaults.
      #
      # @param [String] path
      #   metadata.json full path
      #
      # @return [Hash]
      #   content of metadata.json
      #
      # @api private
      def metadata(path = 'metadata.json')
        if @metadata.nil?
          @metadata = JSON.parse(File.read(path)).freeze
          logger.debug function: 'PuppetModule.metadata',
                       file_path: path, text: 'loaded'
        end
        @metadata
      rescue Errno::ENOENT
        logger.debug function: 'PuppetModule.metadata',
                     file_path: path, text: 'not found'

        Modulefile.read

        default_author = 'DevOps Core <devops-core at moneysupermarket.com>'
        dependencies = Modulefile.dependencies.collect do |name, requirement, _|
          {
            'name' => name.sub(%r{^MSMFG/puppet-}, 'MSMFG/'),
            'version_requirement' => requirement
          }
        end

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

      # What an MSMFG puppet module should look like on the filesystem
      #
      # If not specified, module's name is guessed from `Modulefile` and then
      # `metadata.json`, if available. If not, for example you are creating a new
      # module, module's name is taken from environment variable `MODULE_NAME`.
      # If environment variable is not present, module's name is taken from
      # current working directory.
      #
      # @return [String]
      #   the name of the puppet module
      #
      # @api private
      def name
        if @name.nil?
          self.name = Modulefile.name ||
                      metadata['name'] ||
                      ENV['MODULE_NAME'] ||
                      File.basename(Dir.pwd)
        end
        @name
      end

      # Sets the name of the puppet module
      #
      # @param [String] value
      #   The name of the puppet module.
      #
      # @return [String]
      #   the name of the puppet module
      #
      # @example name
      #   MSMFGSpecHelper::PuppetModule.name = 'msmfg-something'
      #
      # @api public
      def name=(value)
        @name = value
        logger.debug function: 'PuppetModule.name', text: "set to #{@name}"
        @name
      end

      # Returns class name (or the module name without the provider prefix)
      #
      # @return [String]
      #   the module's main class name
      #
      # @api private
      def class_name
        name.split('-').last.freeze
      end

      # Return the module's initial fixtures configuration
      #
      # @return [Hash]
      #   the module's fixtures configuration
      #
      # @api private
      def fixtures(path = '.fixture.yml')
        @fixtures ||= begin
          @fixtures = YAML.safe_load(File.read(path)).freeze
          logger.debug function: 'PuppetModule.fixtures',
                       file_path: path, text: 'loaded'
          @fixtures.freeze
        end
      rescue Errno::ENOENT
        logger.debug function: 'PuppetModule.fixtures',
                     file_path: path, text: 'not found'

        PuppetForge.user_agent = "msmfg_spec_helper/#{MSMFGSpecHelper::VERSION}"
        PuppetForge.host = ENV['PUPPETFORGE_HOST'] if ENV['PUPPETFORGE_HOST']
        logger.debug function: 'PuppetModule.fixtures',
                     text: "PuppetForge.host = #{PuppetForge.host}"

        Github.configure do |conf|
          conf.basic_auth = "#{ENV['GITHUB_USER']}:#{ENV['GITHUB_PASSWORD']}"
          basic_auth = "#{ENV['GITHUB_USER']}:i_didn_t_start_yesterday"
          logger.debug function: 'PuppetModule.fixtures',
                       text: "Github.basic_auth = #{basic_auth}"

          conf.endpoint = ENV['GITHUB_ENDPOINT'] if ENV['GITHUB_ENDPOINT']
          logger.debug function: 'PuppetModule.fixtures',
                       text: "GitHub.endpoint = #{conf.endpoint}"

          conf.site = "https://#{ENV['GITHUB_SITE']}" if ENV['GITHUB_SITE']
          logger.debug function: 'PuppetModule.fixtures',
                       text: "GitHub.site = #{conf.site}"
        end

        @fixtures = {
          'fixtures' => {
            'symlinks' => {
              class_name => '#{source_dir}'
            }
          }
        }

        repositories, forge_modules = find_dependencies

        @fixtures['repositories'] = repositories if repositories.any?
        @fixtures['forge_modules'] = forge_modules if forge_modules.any?
        @fixtures.freeze
      end

      # Lookup puppet module dependencies either on `Github` or `PuppetForge`
      #
      # @return [Array<Hash>]
      #   `repositories` and `forge_modules`
      #
      # @api private
      def find_dependencies
        forge_modules = {}
        repositories = {}

        metadata['dependencies'].each do |dep|
          provider_name, module_name = dep['name'].split('/', 2)

          # Just for logging
          file_path = "#{dep['name']} #{dep['version_requirement']}"

          logger.debug function: 'PuppetModule.fixtures:',
                       file_path: file_path, text: 'looking up'

          # Build the arguments for the lookup function call
          group, lookup = case provider_name
                          when 'MSMFG' then [repositories, :find_repository]
                          else [forge_modules, :find_forge_module]
                          end

          # Call the lookup function
          candidate = send(lookup, provider_name, module_name,
                           dep['version_requirement'])
          if candidate
            group[module_name] = candidate
            logger.debug function: 'PuppetModule.fixtures', file_path: file_path,
                         text: "using #{candidate['repo']} #{candidate['ref']}"
          else
            logger.error function:  'PuppetModule.fixtures',
                         file_path: file_path, text: 'no candidate'
          end
        end

        [repositories, forge_modules]
      end

      private :find_dependencies

      # Use `semantic_puppet` to parse version string.
      #
      # @param [String] ref
      #   the version string
      #
      # @return [SemanticPuppet::Version, nil]
      #   The `semantic_puppet` version object, or nil
      #
      # @api private
      def semantic_version(ref)
        SemanticPuppet::Version.parse(ref)
      rescue => error
        logger.warn function: 'PuppetModule.semantic_version',
                    file_path: ref, text: error
        nil
      end

      private :semantic_version

      # Looks for the latest repository release, matching requirements
      #
      # @param [String] organization
      #   the puppet module provider name (MSMFG)
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
      def find_repository(organization, module_name, requirement)
        repo_name = "puppet-#{module_name}"
        repo = "#{Github.configuration.site}/MSMFG/#{repo_name}.git"

        range = SemanticPuppet::VersionRange.parse(requirement)

        # Let's query GitHub
        client = Github::Client::Repos::Releases.new

        releases = client.list(organization, repo_name).to_a
        releases.collect! { |r| semantic_version(r.tag_name) }

        ref = releases.select { |r| r && range.cover?(r) }.max
        { 'repo' => repo, 'ref' => ref.to_s } if ref
      rescue => error
        logger.error function: 'PuppetModule.find_repository',
                     file_path: "#{repo_name} #{requirement}", text: error
        nil
      end

      private :find_repository

      # Looks for the latest puppet forge module, matching requirements
      #
      # @param [String] provider_name
      #   the puppet module provider name
      #
      # @param [String] module_name
      #   the puppet module name
      #
      # @param [String] requirement
      #   the version requirement specification
      #
      # @return [Hash]
      #   puppet forge module info, or `nil`
      #
      # @api private
      def find_forge_module(provider_name, module_name, requirement)
        # Let's query the PuppetForge
        name = "#{provider_name}-#{module_name}"

        range = SemanticPuppet::VersionRange.parse(requirement)

        releases = PuppetForge::Module.find(name).releases.to_a
        releases.collect! { |r| semantic_version(r.version) }

        ref = releases.select { |r| r && range.cover?(r) }.max

        { 'repo' => name, 'ref' => ref.to_s } if ref
      rescue => error
        logger.error function: 'PuppetModule.find_forge_module',
                     file_path: "#{name} #{requirement}", text: error
        nil
      end

      private :find_forge_module

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
    let(:puppet_apply) { apply_manifest pp, catch_failures: true }

    context 'first run' do
      it 'runs without errors' do
        expect(puppet_apply.exit_code).to eq(0) | eq(2)
      end
    end

    context 'second run' do
      it 'runs without changes' do
        expect(puppet_apply.exit_code).to eq 0
      end
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
              # Untill we use our PuppetForge
              metadata_ = JSON.parse(JSON.dump(metadata))
              metadata_['dependencies'].reject! { |r| r['name'] =~ %r{^MSMFG/} }
              File.write(file.name, JSON.pretty_generate(metadata_))
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
            requires: ['metadata.json'],
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
              # Bundler.ui = Bundler::UI::Shell.new
              Bundler::CLI::Install.new('jobs' => 7).run
            end
          },
          {
            name: 'spec/acceptance/nodesets/default.yml',
            create: proc do |file|
              ENV['DOCKER_REGISTRY'] ||= 'registry1-eu1.moneysupermarket.com:5000'
              nodeset = {
                'HOSTS' => {
                  'centos_6.7-ruby_2.1.5-puppet_3.7.4' => {
                    'platform' => 'el-6-x86_64',
                    'image' => "#{ENV['DOCKER_REGISTRY']}/centos_6.7-ruby_2.1.5-puppet_3.7.4:latest",
                    'hypervisor' => 'docker',
                    'docker_container_name' => 'centos_6.7'
                  }
                },
                'CONFIG' => {
                  'log_level' => 'warn',
                  'quite' => true,
                  'type' => 'foss',
                  'masterless' => true
                }
              }
              File.write(file.name, YAML.dump(nodeset))
            end
          },
          {
            name: 'spec/spec_helper.rb',
            requires: ['spec/acceptance/nodesets/default.yml', '.fixtures.yml'],
            create: proc do |file|
              lib = 'msmfg_spec_helper/puppet_module/spec_helper'
              File.write(file.name, "require '#{lib}'\n")
            end
          },
          {
            name: 'spec/spec_helper_acceptance.rb',
            requires: ['spec/acceptance/nodesets/default.yml', '.fixtures.yml'],
            create: proc do |file|
              lib = 'msmfg_spec_helper/puppet_module/spec_helper_acceptance'
              File.write(file.name, "require '#{lib}'\n")
            end
          },
          {
            name: "spec/classes/#{class_name}_spec.rb",
            requires: ['spec/spec_helper.rb'],
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
end
