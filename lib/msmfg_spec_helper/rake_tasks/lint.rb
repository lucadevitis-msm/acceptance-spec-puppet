require 'msmfg_spec_helper'
require 'puppet-lint/tasks/puppet-lint'
require 'rubocop/rake_task'

# rubocop:disable Metrics/BlockLength
namespace :lint do
  logger = MSMFGSpecHelper::Logger.instance
  include MSMFGSpecHelper::FilesListsMixIn

  desc 'Lint metadata.json'
  task :metadata_json do
    report = {
      task: 'lint',
      file_type: 'metadata_json',
      file_path: 'metadata.json'
    }
    begin
      if ::File.file? 'metadata.json'
        MetadataJsonLint.options[:strict_dependencies] = true
        MetadataJsonLint.parse('metadata.json')
        logger.info report
      end
    rescue => error
      logger.error report.merge(text: error)
      raise
    end
  end

  desc 'Lint puppet manifests'
  task :manifests do
    PuppetLint::OptParser.build.load(File.join(DATADIR, 'puppet-lint.rc'))

    linter = PuppetLint.new
    manifests.each do |manifest|
      report = { task: 'lint', file_type: 'manifest', file_path: manifest }
      linter.file = manifest
      linter.run
      problems = linter.problems.collect do |problem|
        next unless [:error, :warning].include? problem[:kind]
        problem[:kind] = :warn if problem[:kind] == :warning
        logger.send problem[:kind],
                    report.merge(file_line: problem[:line],
                                 check_name: problem[:check],
                                 text: problem[:message])
        problem
      end
      abort if problems.any?
      logger.info report
    end
  end

  RuboCop::RakeTask.new :ruby do |rubocop|
    rubocop.verbose = false
    rubocop.requires << 'rubocop-rspec'
    rubocop.requires << 'rubocop/formatter/msmfg_spec_helper_formatter'
    rubocop.patterns = ruby_files

    formatter = 'RuboCop::Formatter::MSMFGSpecHelperFormatter'
    config = File.join(DATADIR, 'rubocop.yml')
    rubocop.options = ['--config', config, '--format', formatter]
  end
end
# rubocop:enable Metrics/BlockLength

Rake::Task[:lint].clear
desc 'Run all the lint checks'
task :lint do
  [:'lint:metadata_json',
   :'lint:manifests',
   :'lint:ruby'].each { |lint_check| Rake::Task[lint_check].invoke }
end
