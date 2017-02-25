require 'msmfg_spec_helper'
require 'msmfg_spec_helper/rake_tasks/validate'
require 'rspec/core/rake_task'

desc 'Check the module against MSMFG acceptance specs'
RSpec::Core::RakeTask.new :msmfg_puppet_module do |rspec|
  include MSMFGSpecHelper::FilesListsMixIn
  rspec.pattern = File.join(DATADIR, 'msmfg_acceptance_spec.rb')
  rspec.rspec_opts = '--color --format documentation'
  unless ENV['VERBOSE']
    rspec.ruby_opts = '-W0'
    rspec.verbose = false
  end
end

task validate: [:msmfg_puppet_module]
