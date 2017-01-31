# rubocop:disable Metrics/LineLength
require 'msmfg_spec_helper/rake_tasks/helpers'
require 'puppetlabs_spec_helper/rake_tasks'

# Tasks list:
# rake beaker                # Run beaker acceptance tests
# rake beaker:sets           # List available beaker nodesets
# rake beaker:ssh[set,node]  # Try to use vagrant to login to the Beaker node
# rake build                 # Build puppet module package
# rake check:dot_underscore  # Fails if any ._ files are present in directory
# rake check:git_ignore      # Fails if directories contain the files specified in .gitignore
# rake check:symlinks        # Fails if symlinks are present in directory
# rake check:test_file       # Fails if .pp files present in tests folder
# rake clean                 # Clean a built module package
# rake compute_dev_version   # Print development version of module
# rake help                  # Display the list of available rake tasks
# rake lint                  # Run puppet-lint
# rake metadata_lint         # Run metadata-json-lint
# rake parallel_spec         # Parallel spec tests
# rake release_checks        # Runs all necessary checks on a module in preparation for a release
# rake rubocop               # Run RuboCop
# rake rubocop:auto_correct  # Auto-correct RuboCop offenses
# rake spec                  # Run spec tests and clean the fixtures directory if successful
# rake spec_clean            # Clean up the fixtures directory
# rake spec_prep             # Create the fixtures directory
# rake spec_standalone       # Run spec tests on an existing fixtures directory
# rake syntax                # Syntax check Puppet manifests and templates
# rake syntax:hiera          # Syntax check Hiera config files
# rake syntax:manifests      # Syntax check Puppet manifests
# rake syntax:templates      # Syntax check Puppet templates
# rake validate              # Check syntax of Ruby files and call :syntax and :metadata_lint
[
  'build',
  'check:dot_underscore',
  'check:git_ignore',
  'check:symlinks',
  'check:test_file',
  'clean',
  'compute_dev_version',
  'help',
  'lint',
  'metadata_lint',
  'parallel_spec',
  'release_checks',
  'rubocop',
  'rubocop:auto_correct',
  'spec_standalone',
  'syntax',
  'syntax:hiera',
  'syntax:manifests',
  'syntax:templates',
  'validate'
].each do |name|
  Rake::Task[name].clear
end

desc 'Run spec tests on an existing fixtures directory'
RSpec::Core::RakeTask.new :spec_standalone do |rspec|
  include MSMFGSpecHelper::RakeTasks::Helpers
  rspec.pattern = 'spec/{classes,defines,unit,functions,hosts,integration,types}/**/*_spec.rb'
  rspec.ruby_opts = '-W0'
  rspec.rspec_opts = '--color --format documentation'
  rspec.verbose = false
end

desc 'Run beaker acceptance tests'
RSpec::Core::RakeTask.new :beaker do |rspec|
  include MSMFGSpecHelper::RakeTasks::Helpers
  rspec.pattern = 'spec/acceptance/**/*_spec.rb'
  rspec.ruby_opts = '-W0'
  rspec.rspec_opts = '--color --format documentation'
  rspec.verbose = false
end
