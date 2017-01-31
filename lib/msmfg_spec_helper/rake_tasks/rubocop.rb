require 'msmfg_spec_helper/rake_tasks/helpers'
require 'rubocop/rake_task'

RuboCop::RakeTask.new :rubocop do |rubocop|
  include MSMFGSpecHelper::RakeTasks::Helpers
  rubocop.patterns = ruby_files
  rubocop.options = ['--config', File.join(DATADIR, 'rubocop.yml'), '--color']
end
