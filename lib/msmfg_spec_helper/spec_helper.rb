require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start do
  minimum_coverage 100
  minimum_coverage_by_file 100
  refuse_coverage_drop
  add_filter '/spec/'
  add_filter '/.vendor/'
end

require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |hook|
  hook.after :suite do
    RSpec::Puppet::Coverage.report!
    SimpleCov.result.format!
  end
end
