require 'msmfg_spec_helper'
require 'rubocop/rake_task'

RuboCop::RakeTask.new :rubocop do |rubocop|
  include MSMFGSpecHelper
  rubocop.patterns = ruby_files
  rubocop.options = ['--config', File.join(DATADIR, 'rubocop.yml'), '--color']
end
