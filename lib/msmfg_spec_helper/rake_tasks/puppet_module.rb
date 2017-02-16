# rubocop:disable Metrics/LineLength
require 'puppetlabs_spec_helper/rake_tasks'

# This is going to create a lot of tasks we are going to redefine:
#
# beaker                # Run beaker acceptance tests
# beaker:sets           # List available beaker nodesets
# beaker:ssh[set,node]  # Try to use vagrant to login to the Beaker node
# build                 # Build puppet module package
# check:dot_underscore  # Fails if any ._ files are present in directory
# check:git_ignore      # Fails if directories contain the files specified in .gitignore
# check:symlinks        # Fails if symlinks are present in directory
# check:test_file       # Fails if .pp files present in tests folder
# clean                 # Clean a built module package
# compute_dev_version   # Print development version of module
# help                  # Display the list of available rake tasks
# lint                  # Run puppet-lint
# metadata_lint         # Run metadata-json-lint
# parallel_spec         # Parallel spec tests
# release_checks        # Runs all necessary checks on a module in preparation for a release
# rubocop               # Run RuboCop
# rubocop:auto_correct  # Auto-correct RuboCop offenses
# spec                  # Run spec tests and clean the fixtures directory if successful
# spec_clean            # Clean up the fixtures directory
# spec_prep             # Create the fixtures directory
# spec_standalone       # Run spec tests on an existing fixtures directory
# syntax                # Syntax check Puppet manifests and templates
# syntax:hiera          # Syntax check Hiera config files
# syntax:manifests      # Syntax check Puppet manifests
# syntax:templates      # Syntax check Puppet templates
# validate              # Check syntax of Ruby files and call :syntax and :metadata_lint
[
  # 'build',
  'check:dot_underscore',
  'check:git_ignore',
  'check:symlinks',
  'check:test_file',
  'compute_dev_version',
  'help',
  'lint',
  'metadata_lint',
  'parallel_spec',
  'release_checks',
  'rubocop',
  'rubocop:auto_correct',
  'spec_standalone',
  # 'strings:generate',
  # 'strings:gh-pages',
  'syntax',
  'syntax:hiera',
  'syntax:manifests',
  'syntax:templates',
  'validate'
].each do |name|
  Rake::Task[name].clear
end

require 'msmfg_spec_helper/rake_tasks/puppet_module/create'
require 'msmfg_spec_helper/rake_tasks/puppet_module/spec'
require 'msmfg_spec_helper/rake_tasks/puppet_module/validate'
require 'rake/clean'

CLEAN.include %w(.yardoc coverage log junit) # :nodoc:
CLOBBER.include %(doc pkg) # :nodoc:

task :build do
  patterns = PuppetStrings::DEFAULT_SEARCH_PATTERNS
  PuppetStrings.generate(patterns, yard_args: %w(--output-dir docs))
end
