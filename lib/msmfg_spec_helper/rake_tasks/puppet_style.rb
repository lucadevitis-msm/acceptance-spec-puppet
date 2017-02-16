require 'msmfg_spec_helper'
require 'puppet-lint/tasks/puppet-lint'

Rake::Task[:lint].clear
desc 'Run puppet-lint'
task :puppet_style do
  include MSMFGSpecHelper::FilesListsMixIn
  include MSMFGSpecHelper::LoggerMixIn

  PuppetLint::OptParser.build.load(File.join(DATADIR, 'puppet-lint.rc'))

  linter = PuppetLint.new
  logger.info('rake_task: puppet_style: checking puppet manifests style...')
  manifests.each do |manifest|
    logger.debug("rake_task: puppet_style: checking #{manifest} ...")
    linter.file = manifest
    linter.run
    linter.print_problems
    if linter.errors? || linter.warnings?
      logger.fatal("rake_task: puppet_style: #{manifest} is not clean")
      abort
    end
    logger.debug("rake_task: puppet_style: #{manifest} is clean")
  end
end
