require 'msmfg_spec_helper/rake_tasks/ruby_style'
require 'msmfg_spec_helper/rake_tasks/syntax'
require 'msmfg_spec_helper/rake_tasks/docs_coverage'
require 'bundler/gem_tasks'

# Yardstick::Rake::Verify.new(:yard_coverage) do |verify|
#   verify.threshold = 100
# end

desc 'Run syntax check, module spec and linters'
task :validate, [:module_path] => [:syntax, :ruby_style]
