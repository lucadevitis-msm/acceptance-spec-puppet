# rubocop:disable Metrics/LineLength
require 'msmfg_spec_helper/puppet_module'
require 'rspec/core/rake_task'

desc 'Run spec tests on an existing fixtures directory'
RSpec::Core::RakeTask.new :spec_standalone do |rspec|
  rspec.pattern = 'spec/{classes,defines,unit,functions,hosts,integration,types}/**/*_spec.rb'
  rspec.rspec_opts = '--color --format documentation'
  unless ENV['VERBOSE']
    rspec.ruby_opts = '-W0'
    rspec.verbose = false
  end
end

desc 'Run beaker acceptance tests'
RSpec::Core::RakeTask.new :beaker do |rspec|
  rspec.pattern = 'spec/acceptance/**/*_spec.rb'
  rspec.rspec_opts = '--color --format documentation'
  ENV['DOCKER_REGISTRY'] ||= 'https://registry1-eu1.moneysupermarket.com:5000'
  unless ENV['VERBOSE']
    rspec.ruby_opts = '-W0'
    rspec.verbose = false
  end
end
