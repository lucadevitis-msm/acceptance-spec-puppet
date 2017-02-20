require 'msmfg_spec_helper'
require 'puppet-lint/tasks/puppet-lint'

Rake::Task[:lint].clear
desc 'Run puppet-lint'
task :puppet_style do
  include MSMFGSpecHelper::FilesListsMixIn
  logger = MSMFGSpecHelper::Logger.instance
  PuppetLint::OptParser.build.load(File.join(DATADIR, 'puppet-lint.rc'))

  linter = PuppetLint.new
  manifests.each do |manifest|
    linter.file = manifest
    linter.run
    linter.print_problems
    if linter.errors? || linter.warnings?
      logger.fatal("task: style: puppet: KO: #{manifest}: #{linter.problems}")
      abort
    end
    logger.debug("task: style: puppet: OK: #{manifest}")
  end
end
