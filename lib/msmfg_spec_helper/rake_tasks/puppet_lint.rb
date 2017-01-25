require 'msmfg_spec_helper/rake_tasks/helpers'
require 'puppet-lint/tasks/puppet-lint'

Rake::Task[:lint].clear
desc 'Run puppet-lint'
task :puppet_lint, [:module_path] do |_, args|
  include MSMFGSpecHelper::RakeTasks::Helpers

  # Defaults
  PuppetLint.configuration.disable_80chars
  PuppetLint.configuration.disable_140chars
  PuppetLint.configuration.relative = true
  # PuppetLint.configuration.fail_on_warnings = true
  PuppetLint.configuration.error_level = :all
  PuppetLint.configuration.log_format = '%{path}: %{kind}: %{message}'
  PuppetLint.configuration.show_ignored = true
  PuppetLint.configuration.with_context = true

  rc = File.join(Gem.datadir('msmfg-spec-helper'), 'puppet-lint.rc')
  PuppetLint::OptParser.build.load(rc) if File.file? rc

  linter = PuppetLint.new
  puts 'Running puppet-lint...'
  manifests(args).each do |manifest|
    linter.file = manifest
    linter.run
    linter.print_problems
    abort if linter.errors? || linter.warnings?
  end
end
