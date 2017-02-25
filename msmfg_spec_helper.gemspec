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
  spec.homepage = 'https://lucadevitis-msm.github.io/msmfg_spec_helper'
  spec.license = 'proprietary'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  spec.metadata['allowed_push_host'] = 'https://artifactory3-eu1.moneysupermarket.com/artifactory/api/gems/gems-local'

  spec.files = `git ls-files -z bin lib data`.split("\x0")
  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  # spec.require_paths = %w(lib data)

  spec.add_runtime_dependency('beaker-facter', '~> 0.1.2')
  spec.add_runtime_dependency('beaker-rspec', '~> 6.0.0')
  spec.add_runtime_dependency('bundler', '~> 1.11')
  spec.add_runtime_dependency('github_api', '~> 0.14.0')
  spec.add_runtime_dependency('hiera-puppet-helper', '~> 1.0.0')
  spec.add_runtime_dependency('markdown', '~> 1.2.0')
  spec.add_runtime_dependency('metadata-json-lint', '~> 1.0.0')
  # https://tickets.puppetlabs.com/browse/BKR-1034
  spec.add_runtime_dependency('net-ssh', '>= 2.6.5')
  spec.add_runtime_dependency('pry')
  spec.add_runtime_dependency('pry-doc')
  spec.add_runtime_dependency('puppet', '~> 3.7.4')
  spec.add_runtime_dependency('puppetlabs_spec_helper', '~> 1.2.0')
  spec.add_runtime_dependency('puppet-strings', '~> 1.0.0')
  spec.add_runtime_dependency('puppet_forge', '~> 2.2.0')
  spec.add_runtime_dependency('rake', '~> 10.0')
  spec.add_runtime_dependency('rdoc', '~> 4.2.0')
  spec.add_runtime_dependency('rubocop', '~> 0.47.1')
  spec.add_runtime_dependency('rubocop-rspec', '~> 1.12.0')
  spec.add_runtime_dependency('safe_yaml', '~> 1.0.0')
  spec.add_runtime_dependency('simplecov', '~> 0.12.0')
  spec.add_runtime_dependency('simplecov-html', '~> 0.10.0')
end
