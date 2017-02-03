require 'rake'

module MSMFGSpecHelper
  def self.rake_application(app_name, &block)
    Rake.application.standard_exception_handling do
      Rake.application.init(app_name)
      Rake::TaskManager.record_task_metadata = true

      yield

      Rake.application.top_level
    end
  end
end
