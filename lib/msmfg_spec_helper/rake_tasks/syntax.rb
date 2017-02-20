require 'metadata_json_lint'
require 'msmfg_spec_helper'
require 'puppet-syntax'
require 'rake'

# rubocop:disable Metrics/BlockLength
namespace :syntax do
  include MSMFGSpecHelper::FilesListsMixIn

  desc 'Check ruby files syntax (ruby -c)'
  task :ruby do
    ruby_files.each do |rb|
      logger = MSMFGSpecHelper::Logger.instance
      begin
        sh "ruby -c #{rb} &> /dev/null", verbose: false
        logger.info("task: syntax: ruby: OK: #{rb}")
      rescue => e
        logger.fatal("task: syntax: ruby: KO: #{rb}: #{e}")
        raise
      end
    end
  end

  desc 'Check metadata.json syntax (metadata-json-lint)'
  task :metadata_json do
    logger = MSMFGSpecHelper::Logger.instance
    begin
      if ::File.file? 'metadata.json'
        MetadataJsonLint.options[:strict_dependencies] = true
        MetadataJsonLint.parse('metadata.json')
        logger.info('task: syntax: metadata_json: OK')
      end
    rescue => e
      logger.fatal("task: syntax: metadata_json: KO: #{e}")
      raise
    end
  end

  desc 'Check puppet manifests syntax'
  task :manifests do
    logger = MSMFGSpecHelper::Logger.instance
    syntax = PuppetSyntax::Manifests.new
    manifests.each do |manifest|
      errors, = syntax.check([manifest])
      if errors.any?
        errors.each do |e|
          logger.fatal("task: syntax: manifests: KO: #{manifest}: #{e}")
        end
        abort
      end
      logger.info("task: syntax: manifests: OK: #{manifest}")
    end
  end

  desc 'Check templates syntax'
  task :templates do
    logger = MSMFGSpecHelper::Logger.instance
    syntax = PuppetSyntax::Templates.new
    templates.each do |template|
      errors = syntax.check([template])
      if errors.any?
        errors.each do |e|
          logger.fatal("task: syntax: templates: KO: #{template}: #{e}")
        end
        abort
      end
      logger.info("task: syntax: templates: OK: #{template}")
    end
  end

  desc 'Check hieradata syntax'
  task :hieradata do
    logger = MSMFGSpecHelper::Logger.instance
    hieradata.each do |data|
      begin
        YAML.safe_load(data)
        logger.info("task: syntax: hieradata: OK: #{data}")
      rescue => e
        logger.fatal("task: syntax: hieradata: KO: #{data}: #{e}")
        raise
      end
    end
  end

  desc 'Check fragment syntax'
  task :fragments do
    logger = MSMFGSpecHelper::Logger.instance
    fragments.each do |fragment|
      begin
        YAML.safe_load(fragment)
        logger.info("task: syntax: fragments: OK: #{fragment}")
      rescue => e
        logger.fatal("task: syntax: fragments: KO: #{fragment}: #{e}")
        raise
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength

desc 'Run all the syntax checks'
task :syntax do
  [:'syntax:ruby',
   :'syntax:metadata_json',
   :'syntax:manifests',
   :'syntax:templates',
   :'syntax:hieradata',
   :'syntax:fragments'].each { |syntax_check| Rake::Task[syntax_check].invoke }
end
