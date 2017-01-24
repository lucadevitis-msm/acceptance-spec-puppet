# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec_brownbag/version'

Gem::Specification.new do |spec|
  raise 'RubyGems 2.0 or newer is required.' unless spec.respond_to?(:metadata)
  spec.name = 'rspec-brownbag'
  spec.version = RSpecBrownbag::VERSION
  spec.authors = ['Luca De Vitis']
  spec.email = ['luca.devitis at moneysupermarket.com']

  spec.summary = 'RSpec brownbag'
  spec.description = 'Set of examples for a brownbag session about RSpec'
  spec.homepage = 'https://github.com/lucadevitis-msm/brownbags/rspec'
  spec.license = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  spec.metadata['allowed_push_host'] = 'http://mygemserver.com'

  spec.files = `git ls-files -z`.split("\x0")
  spec.files.reject! { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib', 'rubocop.yml']
end
