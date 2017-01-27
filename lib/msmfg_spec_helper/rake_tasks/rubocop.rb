require 'msmfg_spec_helper/rake_tasks/helpers'
require 'rubocop/rake_task'

RuboCop::RakeTask.new :rubocop, [:module_path] do |rubocop, args|
  include MSMFGSpecHelper::RakeTasks::Helpers
  rubocop.patterns = ruby_files(args)
  config = File.join(Gem.datadir('msmfg-spec-helper'), 'rubocop.yml')
  rubocop.options = %W(--config #{config} --color)
end
