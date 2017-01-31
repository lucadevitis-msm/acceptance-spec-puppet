require 'msmfg_spec_helper/rake_tasks/helpers'
require 'puppet-lint/tasks/puppet-lint'

Rake::Task[:lint].clear
desc 'Run puppet-lint'
task :puppet_lint do
  include MSMFGSpecHelper::RakeTasks::Helpers

  PuppetLint::OptParser.build.load(File.join(DATADIR, 'puppet-lint.rc'))

  linter = PuppetLint.new
  puts 'Running puppet-lint...'
  manifests.each do |manifest|
    linter.file = manifest
    linter.run
    linter.print_problems
    abort if linter.errors? || linter.warnings?
  end
end
