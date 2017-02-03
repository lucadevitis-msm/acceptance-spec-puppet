require 'msmfg_spec_helper/rake_tasks/helpers'
require 'msmfg_spec_helper/rake_tasks/puppet_lint'
require 'msmfg_spec_helper/rake_tasks/rubocop'
require 'msmfg_spec_helper/rake_tasks/syntax'
require 'rspec/core/rake_task'

desc 'Check the module against MSMFG acceptance specs'
RSpec::Core::RakeTask.new :module_spec do |rspec|
  rspec.pattern = File.join(Gem.datadir('msmfg_spec_helper'), 'module_spec.rb')
  rspec.rspec_opts = '--color --format documentation'
  unless ENV['VERBOSE']
    rspec.ruby_opts = '-W0' 
    rspec.verbose = false
  end
end

desc 'Run syntax check, module spec and linters'
task validate: [:syntax, :rubocop, :puppet_lint, :module_spec]
