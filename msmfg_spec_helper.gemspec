# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'msmfg_spec_helper/version'

Gem::Specification.new do |spec|
  raise 'RubyGems 2.0 or newer is required.' unless spec.respond_to?(:metadata)
  spec.name = 'msmfg_spec_helper'
  spec.version = MSMFGSpecHelper::VERSION
  spec.authors = ['Luca De Vitis']
  spec.email = ['luca.devitis at moneysupermarket.com']

  spec.summary = 'MSMFG Spec Helper'
  spec.description = 'MSMFG Spec Helper'
  spec.homepage = 'https://github.com/lucadevitis-msm/msmfg_spec_helper'
  spec.license = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  spec.metadata['allowed_push_host'] = 'http://mygemserver.com'

  spec.files = `git ls-files -z bin lib data`.split("\x0")
  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  # spec.require_paths = %w(lib data)

  spec.add_runtime_dependency('beaker-facter')
  spec.add_runtime_dependency('beaker-rspec')
  spec.add_runtime_dependency('bundler', '~> 1.11')
  spec.add_runtime_dependency('coveralls')
  spec.add_runtime_dependency('hiera')
  spec.add_runtime_dependency('hiera-puppet-helper')
  spec.add_runtime_dependency('metadata-json-lint')
  # https://tickets.puppetlabs.com/browse/BKR-1034
  spec.add_runtime_dependency('net-ssh', '>= 2.6.5')
  spec.add_runtime_dependency('pry')
  spec.add_runtime_dependency('puppet', '< 4')
  spec.add_runtime_dependency('puppetlabs_spec_helper')
  spec.add_runtime_dependency('puppet-strings')
  spec.add_runtime_dependency('rake', '~> 10.0')
  spec.add_runtime_dependency('rubocop')
  spec.add_runtime_dependency('safe_yaml')
  spec.add_runtime_dependency('wirble')
  spec.add_runtime_dependency('yardstick')
end
