$VERBOSE = nil
require 'msmfg_spec_helper/rake_tasks/coverage'
require 'msmfg_spec_helper/rake_tasks/lint'
require 'msmfg_spec_helper/rake_tasks/syntax'
require 'bundler/gem_tasks'

# Yardstick::Rake::Verify.new(:yard_coverage) do |verify|
#   verify.threshold = 100
# end

desc 'Run syntax check, module spec and linters'
task validate: [:syntax, :lint, :coverage]

task :docs do
  patterns = PuppetStrings::DEFAULT_SEARCH_PATTERNS
  yard_args = %w(--use-cache --output-dir docs
                 --no-stats --no-progress
                 --markup markdown --markup-provider rdoc)
  PuppetStrings.generate(patterns, yard_args: yard_args)
end
