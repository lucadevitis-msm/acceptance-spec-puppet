require 'msmfg_spec_helper/rake_tasks/syntax'
require 'msmfg_spec_helper/rake_tasks/module_spec'
require 'msmfg_spec_helper/rake_tasks/puppet_lint'
require 'msmfg_spec_helper/rake_tasks/rubocop'
require 'rake/clean'

# `:clean` task is supposed to clean intermediate/temporary files
# `CLEAN` array tells which files to remove on `clean` task.
CLEAN.include %w(.yardoc coverage log junit)

# `:clobber` task is uspposed to clean final products. Requires `:clean` task.
# `CLOBBER` array tells which files to remove on `clobber` task.
CLOBBER.include %(doc pkg)

desc 'Run syntax check, module spec and linters'
task :validate, [:module_path] => [:syntax,
                                   :rubocop,
                                   :puppet_lint,
                                   :module_spec]
