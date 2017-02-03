require 'msmfg_spec_helper/rake_tasks/puppet_lint'
require 'msmfg_spec_helper/rake_tasks/rubocop'
require 'msmfg_spec_helper/rake_tasks/syntax'
require 'bundler/gem_tasks'

desc 'Run syntax check, module spec and linters'
task :validate, [:module_path] => [:syntax, :rubocop, :puppet_lint]
