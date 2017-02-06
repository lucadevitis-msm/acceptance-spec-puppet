require 'msmfg_spec_helper'
require 'msmfg_spec_helper/rake_tasks/puppet_lint'
require 'msmfg_spec_helper/rake_tasks/rubocop'
require 'msmfg_spec_helper/rake_tasks/syntax'
require 'msmfg_spec_helper/rake_tasks/yardstick'
require 'rspec/core/rake_task'

desc 'Check the module against MSMFG acceptance specs'
RSpec::Core::RakeTask.new :module_spec do |rspec|
  include MSMFGSpecHelper
  rspec.pattern = File.join(DATADIR, 'module_spec.rb')
  rspec.rspec_opts = '--color --format documentation'
  unless ENV['VERBOSE']
    rspec.ruby_opts = '-W0'
    rspec.verbose = false
  end
end

desc 'Run syntax check, module spec and linters'
task validate: [:syntax, :rubocop, :puppet_lint, :yardstick, :module_spec]
