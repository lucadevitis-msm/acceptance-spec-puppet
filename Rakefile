$VERBOSE = nil
require 'msmfg_spec_helper/rake_tasks/lint'
require 'msmfg_spec_helper/rake_tasks/syntax'
require 'bundler/gem_tasks'

# Yardstick::Rake::Verify.new(:yard_coverage) do |verify|
#   verify.threshold = 100
# end

desc 'Run syntax check, module spec and linters'
task validate: [:syntax, :lint]
