require 'yardstick/rake/verify'
require 'msmfg_spec_helper'

Yardstick::Rake::Verify.new(:docs_coverage) do |verify|
  require 'puppet-strings'
  require 'puppet-strings/yard'
  PuppetStrings::Yard.setup!
  verify.path = ruby_files.include(manifests)
  verify.verbose = true
  verify.threshold = 100
end
