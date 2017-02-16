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
    logger.info('Checking ruby files syntax...')
    ruby_files.include('**/Puppetfile.*').each do |rb|
      null = if RUBY_PLATFORM =~ /cygwin|mswin|mingw|bccwin|wince|emx/
               'NUL'
             else
               '/dev/null'
             end
      sh "ruby -c #{rb} > #{null}", verbose: false
    end
  end

  desc 'Check metadata.json syntax (metadata-json-lint)'
  task :metadata_json do
    logger.info('Checking metadata.json syntax...')
    # MetadataJsonLint.options[:strict_license] = false
    MetadataJsonLint.parse('metadata.json') if ::File.file? 'metadata.json'
  end

  desc 'Check puppet manifests syntax...'
  task :manifests do
    logger.info('Checking puppet manifests syntax...')
    output, has_errors = PuppetSyntax::Manifests.new.check(manifests)
    if output.any?
      if has_errors
        logger.error(output.join("\n"))
        abort
      else
        logger.warn(output.join("\n"))
      end
    end
  end

  desc 'Check templates syntax'
  task :templates do
    logger.info('Checking templates syntax...')
    errors = PuppetSyntax::Templates.new.check(templates)
    if errors.any?
      logger.error(errors.join("\n"))
      abort
    end
  end

  desc 'Check hieradata syntax'
  task :hieradata do
    logger.info('Checking hieradata files syntax...')
    errors = PuppetSyntax::Hiera.new.check(hieradata)
    if errors.any?
      logger.erorr(errors.join("\n"))
      abort
    end
  end

  desc 'Check fragment syntax'
  task :fragments do
    logger.info('Checking fragments files syntax...')
    errors = fragments.select do |fragment|
      begin
        YAML.safe_load(fragment) && nil
      rescue => e
        "ERROR: Failed to parse #{fragment}: #{e}"
      end
    end
    if errors.any?
      logger.error(errors.compact.join("\n"))
      abort
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
