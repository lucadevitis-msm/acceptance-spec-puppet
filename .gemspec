# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'msmfg_spec_helper/version'

Gem::Specification.new do |spec|
  raise 'RubyGems 2.0 or newer is required.' unless spec.respond_to?(:metadata)
  spec.name = 'msmfg-spec-helper'
  spec.version = MSMFGSpecHelper::VERSION
  spec.authors = ['Luca De Vitis']
  spec.email = ['luca.devitis at moneysupermarket.com']

  spec.summary = 'MSMFG Spec Helper'
  spec.description = 'MSMFG Spec Helper'
  spec.homepage = 'https://github.com/lucadevitis-msm/msmfg-spec-helper'
  spec.license = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  spec.metadata['allowed_push_host'] = 'http://mygemserver.com'

  spec.files = `git ls-files -z lib data`.split("\x0")
  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib data)
end
