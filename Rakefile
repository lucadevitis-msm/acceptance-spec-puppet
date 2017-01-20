require 'puppetlabs_spec_helper/rake_tasks'
require 'rake/clean'

# `:clean` task is supposed to clean intermediate/temporary files
# `CLEAN` array tells which files to remove on `clean` task.
CLEAN.include %w(.yardoc coverage log junit)

# `:clobber` task is uspposed to clean final products. Requires `:clean` task.
# `CLOBBER` array tells which files to remove on `clobber` task.
CLOBBER.include %(doc pkg)

RSpec::Core::RakeTask.new(:msm_module_spec) do |rspec|
  rspec.pattern = 'msm_module_spec.rb'
  rspec.ruby_opts = '-W0'
end
