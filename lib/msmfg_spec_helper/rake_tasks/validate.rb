require 'msmfg_spec_helper/rake_tasks/coverage'
require 'msmfg_spec_helper/rake_tasks/lint'
require 'msmfg_spec_helper/rake_tasks/syntax'

desc 'Run all validation checks'
task validate: [:syntax, :lint, :coverage]
