require 'msmfg_spec_helper'
require 'rubocop/rake_task'

RuboCop::RakeTask.new :ruby_style do |rubocop|
  include MSMFGSpecHelper::FilesListsMixIn
  include MSMFGSpecHelper::LoggerMixIn
  logger.info('rake_task: ruby_style: checking ruby files style...')
  rubocop.patterns = ruby_files
  rubocop.options = ['--config', File.join(DATADIR, 'rubocop.yml'), '--color']
end
