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
      logger.fatal("task: puppet_style: KO: #{manifest}")
      abort
    end
    logger.debug("task: puppet_style: OK: #{manifest}")
  end
end
