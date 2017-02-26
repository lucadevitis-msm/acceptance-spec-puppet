require 'msmfg_spec_helper/files_lists'
require 'msmfg_spec_helper/logger'
require 'puppet-strings'
require 'puppet-strings/yard'
require 'rake'

namespace :coverage do
  task :docs do
    include FilesListsMixIn
    YARD::Registry.lock_for_writing do
      YARD.parse(ruby_files + manifests)
      YARD::Registry.save(true)
    end
    parsed = YARD::Registry.all.group_by { |u| u.file }
    errors = parsed.collect do |path, objects|
      all = objects.count
      documented = objects.reject { |o| o.docstring.empty? }.count
      report = { task: 'docs', file_path: path, text: "#{documented}/#{all}" }
      severity, error = :error, true if documented < all
      logger.send severity || :info , report
      error
    end
    abort if errors.any?
  end
end
