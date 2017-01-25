require 'msmfg_spec_helper/rake_tasks/helpers'
require 'puppet-lint/tasks/puppet-lint'

Rake::Task[:lint].clear
desc 'Run puppet-lint'
task :puppet_lint, [:module_path] do |_, args|
  include MSMFGSpecHelper::RakeTasks::Helpers

  rc = File.join(Gem.datadir('msmfg-spec-helper'), 'puppet-lint.rc')
  PuppetLint::OptParser.build.load(rc)

  linter = PuppetLint.new
  puts 'Running puppet-lint...'
  manifests(args).each do |manifest|
    linter.file = manifest
    linter.run
    linter.print_problems
    abort if linter.errors? || linter.warnings?
  end
end
