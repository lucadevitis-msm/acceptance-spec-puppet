require 'metadata_json_lint'
require 'msmfg_spec_helper'
require 'msmfg_spec_helper/logger'
require 'puppet-syntax'
require 'rake'

# rubocop:disable Metrics/BlockLength
namespace :syntax do
  include MSMFGSpecHelper::FilesListsMixIn
  include MSMFGSpecHelper::LoggerMixIn

  desc 'Check ruby files syntax (ruby -c)'
  task :ruby do
    logger.info('rake_task: syntax_ruby: checking ruby files syntax ...')
    ruby_files.include('**/Puppetfile.*').each do |rb|
      null = if RUBY_PLATFORM =~ /cygwin|mswin|mingw|bccwin|wince|emx/
               'NUL'
             else
               '/dev/null'
             end
      logger.debug("rake_task: syntax_ruby: checking #{rb} ...")
      begin
        sh "ruby -c #{rb} > #{null}", verbose: false
      rescue
        logger.fatal("rake_task: syntax_ruby: #{rb} syntax is wrong")
        raise
      else
        logger.debug("rake_task: syntax_ruby: #{rb} syntax is correct")
      end
    end
  end

  desc 'Check metadata.json syntax (metadata-json-lint)'
  task :metadata_json do
    logger.info('rake_task: metadata_json: checking metadata.json syntax ...')
    # MetadataJsonLint.options[:strict_license] = false
    begin
      MetadataJsonLint.parse('metadata.json') if ::File.file? 'metadata.json'
      logger.fatal("rake_task: metadata_json: metadata.json syntax is wrong")
      raise
    else
      logger.debug("rake_task: metadata_json: metadata.json syntax is correct")
    end
  end

  desc 'Check puppet manifests syntax'
  task :manifests do
    logger.info('rake_task: metadata_json: checking puppet manifests syntax ...')
    output, has_errors = PuppetSyntax::Manifests.new.check(manifests)
    if output.any?
      if has_errors
        logger.fatal('rake_task: metadata_json: manifests syntax is incorrect')
        STDERR.puts(output.join("\n"))
        abort
      else
        logger.warn('rake_task: metadata_json: manifests syntax have problems')
        STDERR.puts(output.join("\n"))
      end
    else
      logger.debug('rake_task: metadata_json: manifests syntax is correct')
    end
  end

  desc 'Check templates syntax'
  task :templates do
    logger.info('rake_task: templates: checking templates syntax ...')
    errors = PuppetSyntax::Templates.new.check(templates)
    if errors.any?
      logger.fatal('rake_task: templates: templates syntax is incorrect')
      STDERR.puts(errors.join("\n"))
      abort
    else
      logger.debug('rake_task: templates: templates syntax is correct')
    end
  end

  desc 'Check hieradata syntax'
  task :hieradata do
    logger.info('rake_task: hieradata: checking hieradata files syntax ...')
    errors = PuppetSyntax::Hiera.new.check(hieradata)
    if errors.any?
      logger.fatal('rake_task: hieradata: hieradata syntax is incorrect')
      STDERR.puts(errors.join("\n"))
      abort
    else
      logger.debug('rake_task: hieradata: hieradata syntax is correct')
    end
  end

  desc 'Check fragment syntax'
  task :fragments do
    logger.info('rake_task: fragments: checking fragments files syntax ...')
    errors = fragments.select do |fragment|
      begin
        YAML.safe_load(fragment) && nil
      rescue => e
        "ERROR: Failed to parse #{fragment}: #{e}"
      end
    end
    if errors.any?
      logger.fatal('rake_task: fragments: fragments syntax is incorrect')
      STDERR.puts(errors.compact.join("\n"))
      abort
    else
      logger.debug('rake_task: fragments: fragments syntax is correct')
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
