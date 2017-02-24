require 'msmfg_spec_helper/files_lists'
require 'msmfg_spec_helper/logger'
require 'puppet-strings'
require 'puppet-strings/yard'
require 'rake'

namespace :coverage do
  task :docs do
    include MSMFGSpecHelper::FilesListsMixIn
    logger = MSMFGSpecHelper::Logger.instance

    PuppetStrings::Yard.setup!

    YARD::Registry.lock_for_writing do
      YARD.parse(ruby_files + manifests)
      YARD::Registry.save(true)
    end

    parsed = YARD::Registry.all.group_by(&:file)
    errors = parsed.collect do |path, objects|
      next unless path
      report = { task: 'docs', file_path: path }
      undocumented = objects.select { |o| o.docstring.empty? }
      undocumented.each do |object|
        logger.fatal report.merge(file_line: object.line,
                                  check_name: object.type,
                                  text: object.name.to_s)
      end
      error = undocumented.any?
      logger.info(report) unless error
      error
    end
    abort if errors.any?
  end
end

desc 'Run all the coverage checks'
task :coverage do
  [:'coverage:docs'].each { |coverage_check| Rake::Task[coverage_check].invoke }
end
