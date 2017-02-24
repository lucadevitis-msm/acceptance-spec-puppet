require 'json'
require 'metadata_json_lint'
require 'msmfg_spec_helper'
require 'open3'
require 'puppet-syntax'
require 'rake'
require 'yaml'

# rubocop:disable Metrics/BlockLength
namespace :syntax do
  include MSMFGSpecHelper::FilesListsMixIn
  logger = MSMFGSpecHelper::Logger.instance

  desc 'Check ruby files syntax'
  task :ruby do
    report = { task: 'syntax', file_type: 'ruby' }
    ruby_files.each do |rb|
      Open3.popen2e('ruby', '-c', rb) do |_, output, thread|
        if thread.value.exitstatus != 0
          _, line, message = output.read.lines.first.split(':', 3)
          logger.error report.merge(file_path: rb,
                                    file_line: line,
                                    text: message.strip)
          abort
        end
        logger.info report.merge(file_path: rb)
      end
    end
  end

  desc 'Check puppet manifests syntax'
  task :manifests do
    report = { task: 'syntax', file_type: 'manifest' }
    syntax = PuppetSyntax::Manifests.new
    manifests.each do |manifest|
      errors, = syntax.check([manifest])
      errors.each do |error|
        logger.error report.merge(file_path: manifest, text: error)
      end
      abort if errors.any?
      logger.info report.merge(file_path: manifest)
    end
  end

  desc 'Check templates syntax'
  task :templates do
    report = { task: 'syntax', file_type: 'template' }
    syntax = PuppetSyntax::Templates.new
    templates.each do |template|
      errors = syntax.check([template])
      errors.each do |error|
        logger.error report.merge(file_path: template, text: error)
      end
      abort if errors.any?
      logger.info report.merge(file_path: template)
    end
  end

  desc 'Check YAML files syntax'
  task :yaml do
    report = { task: 'syntax', file_type: 'yaml' }
    yaml_files.each do |path|
      begin
        YAML.safe_load(path)
        logger.info report.merge(file_path: path)
      rescue => error
        logger.error report.merge(file_path: path, text: error)
        raise
      end
    end
  end

  desc 'Check JSON files syntax'
  task :json do
    report = { task: 'syntax', file_type: 'json' }
    logger = MSMFGSpecHelper::Logger.instance
    json_files.each do |path|
      begin
        JSON.parse(File.read(path))
        logger.info report.merge(file_path: path)
      rescue => error
        logger.error report.merge(file_path: path, text: error)
        raise
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength

desc 'Run all the syntax checks'
task :syntax do
  [:'syntax:ruby',
   :'syntax:manifests',
   :'syntax:templates',
   :'syntax:yaml',
   :'syntax:json'].each { |syntax_check| Rake::Task[syntax_check].invoke }
end
