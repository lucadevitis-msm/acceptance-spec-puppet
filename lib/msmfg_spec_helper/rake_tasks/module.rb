require 'msmfg_spec_helper/rake_tasks/puppetlabs'
require 'msmfg_spec_helper/rake_tasks/helpers'
require 'msmfg_spec_helper/rake_tasks/module_spec'
require 'msmfg_spec_helper/rake_tasks/puppet_lint'
require 'msmfg_spec_helper/rake_tasks/rubocop'
require 'msmfg_spec_helper/rake_tasks/syntax'
require 'rake/clean'
require 'rspec/core/rake_task'

# `:clean` task is supposed to clean intermediate/temporary files
# `CLEAN` array tells which files to remove on `clean` task.
CLEAN.include %w(.yardoc coverage log junit)

# `:clobber` task is uspposed to clean final products. Requires `:clean` task.
# `CLOBBER` array tells which files to remove on `clobber` task.
CLOBBER.include %(doc pkg)

desc 'Check the module against MSMFG acceptance specs'
RSpec::Core::RakeTask.new :module_spec do |rspec|
  include MSMFGSpecHelper::RakeTasks::Helpers
  rspec.pattern = File.join(Gem.datadir('msmfg-spec-helper'), 'module_spec.rb')
  rspec.ruby_opts = '-W0'
  rspec.rspec_opts = '--color --format documentation'
  rspec.verbose = false
end

desc 'Run syntax check, module spec and linters'
task :validate, [:module_path] => [:syntax,
                                   :rubocop,
                                   :puppet_lint,
                                   :module_spec]
