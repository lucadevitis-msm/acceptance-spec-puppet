require 'msmfg_spec_helper'
require 'msmfg_spec_helper/rake_tasks/lint'
require 'msmfg_spec_helper/rake_tasks/syntax'
require 'rspec/core/rake_task'

desc 'Check the module against MSMFG acceptance specs'
RSpec::Core::RakeTask.new :msmfg_acceptance_spec do |rspec|
  include MSMFGSpecHelper::FilesListsMixIn
  rspec.pattern = File.join(DATADIR, 'msmfg_acceptance_spec.rb')
  rspec.rspec_opts = '--color --format documentation'
  unless ENV['VERBOSE']
    rspec.ruby_opts = '-W0'
    rspec.verbose = false
  end
end

desc 'Run syntax check, module spec and linters'
task validate: [:syntax, :lint, :msmfg_acceptance_spec]
