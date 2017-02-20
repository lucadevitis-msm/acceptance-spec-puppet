require 'metadata_json_lint'
require 'msmfg_spec_helper'
require 'puppet-syntax'
require 'rake'

# rubocop:disable Metrics/BlockLength
namespace :syntax do
  include MSMFGSpecHelper::FilesListsMixIn

  desc 'Check ruby files syntax (ruby -c)'
  task :ruby do
    ruby_files.include('**/Puppetfile.*').each do |rb|
      logger = MSMFGSpecHelper::Logger.instance
      null = if RUBY_PLATFORM =~ /cygwin|mswin|mingw|bccwin|wince|emx/
               'NUL'
             else
               '/dev/null'
             end
      begin
        sh "ruby -c #{rb} > #{null}", verbose: false
      rescue => e
        logger.fatal("task: syntax: ruby: KO: #{rb}: #{e}")
        raise
      else
        logger.info("task: syntax: ruby: OK: #{rb}")
      end
    end
  end

  desc 'Check metadata.json syntax (metadata-json-lint)'
  task :metadata_json do
    logger = MSMFGSpecHelper::Logger.instance
    # MetadataJsonLint.options[:strict_license] = false
    begin
      MetadataJsonLint.parse('metadata.json') if ::File.file? 'metadata.json'
    rescue => e
      logger.fatal("task: syntax: metadata_json: KO: #{e}")
      raise
    else
      logger.info('task: syntax: metadata_json: OK')
    end
  end

  desc 'Check puppet manifests syntax'
  task :manifests do
    logger = MSMFGSpecHelper::Logger.instance
    output, = PuppetSyntax::Manifests.new.check(manifests)
    if output.any?
      output.each do |error|
        logger.fatal("task: syntax: manifests: KO: #{error}")
      end
      abort
    else
      logger.info('task: syntax: manifests: OK')
    end
  end

  desc 'Check templates syntax'
  task :templates do
    logger = MSMFGSpecHelper::Logger.instance
    errors = PuppetSyntax::Templates.new.check(templates)
    if errors.any?
      errors.each do |error|
        logger.fatal("task: syntax: templates: KO: #{error}")
      end
      abort
    else
      logger.info('task: syntax: templates: OK')
    end
  end

  desc 'Check hieradata syntax'
  task :hieradata do
    logger = MSMFGSpecHelper::Logger.instance
    errors = hieradata.select do |data|
      begin
        YAML.safe_load(data)
        logger.info("task: syntax: fragments: OK: #{data}")
        false
      rescue => e
        logger.fatal("task: syntax: fragments: KO: #{data}: #{e}")
        true
      end
    end
    abort if errors.any?
  end

  desc 'Check fragment syntax'
  task :fragments do
    logger = MSMFGSpecHelper::Logger.instance
    errors = fragments.select do |fragment|
      begin
        YAML.safe_load(fragment)
        logger.info("task: syntax: fragments: OK: #{fragment}")
        false
      rescue => e
        logger.fatal("task: syntax: fragments: KO: #{fragment}: #{e}")
        true
      end
    end
    abort if errors.any?
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
