require 'msmfg_spec_helper/rake_tasks/rubocop'
require 'msmfg_spec_helper/rake_tasks/syntax'
require 'bundler/gem_tasks'
require 'yardstick/rake/verify'

Yardstick::Rake::Verify.new(:yard_coverage) do |verify|
  verify.threshold = 100
end

desc 'Run syntax check, module spec and linters'
task :validate, [:module_path] => [:syntax, :rubocop, :yard_coverage]
