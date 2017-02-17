require 'msmfg_spec_helper/logger'
require 'rake'

module MSMFGSpecHelper # :nodoc:
  # Creates and run a rake application without sourcing a Rakefile
  #
  # @see http://rake.rubyforge.org/classes/Rake/Application.html
  #   Refer to `Rake::Application.run` method.
  #
  # @param [String] app_name
  #   The application name
  #
  # @return [nil]
  #
  # @api private
  def self.rake_application(app_name)
    MSMFGSpecHelper::Logger.progname = app_name
    if ARGV.include? '--trace'
      ENV['LOG_LEVEL'] = 'DEBUG'
      ENV['LOG_PERROR'] = 'true'
    end
    Rake.application.standard_exception_handling do
      Rake.application.init(app_name)
      # Record tasks description (`desc`) to use in `help` targets
      Rake::TaskManager.record_task_metadata = true
      # Yield to block instead of looking for a rakefile
      yield
      Rake.application.top_level
    end
  end
end
