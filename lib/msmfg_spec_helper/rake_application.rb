require 'rake'

# Group spec helping functions
module MSMFGSpecHelper
  # Creates and run a rake application without sourcing a Rakefile
  def self.rake_application(app_name)
    Rake.application.standard_exception_handling do
      Rake.application.init(app_name)
      Rake::TaskManager.record_task_metadata = true

      yield

      Rake.application.top_level
    end
  end
end
