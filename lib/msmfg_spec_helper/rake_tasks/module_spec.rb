require 'msmfg_spec_helper/rake_tasks/helpers'
require 'rspec/core/rake_task'

desc 'Check the module against MSMFG acceptance specs'
RSpec::Core::RakeTask.new :module_spec, [:module_path] do |rspec, args|
  include MSMFGSpecHelper::RakeTasks::Helpers
  rspec.pattern = File.join(Gem.datadir('msmfg-spec-helper'), 'module_spec.rb')
  rspec.ruby_opts = "-W0 -C#{module_path(args)}"
  rspec.rspec_opts = '--color --format documentation'
  rspec.verbose = false
end
