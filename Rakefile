require 'metadata_json_lint'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax'
require 'rake/clean'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

# `:clean` task is supposed to clean intermediate/temporary files
# `CLEAN` array tells which files to remove on `clean` task.
CLEAN.include %w(.yardoc coverage log junit)

# `:clobber` task is uspposed to clean final products. Requires `:clean` task.
# `CLOBBER` array tells which files to remove on `clobber` task.
CLOBBER.include %(doc pkg)

ARGS_DEFAULTS = { module_path: '.',
                  hieradata_paths: ['**/hieradata/**/*.{,e}yaml'] }.freeze

SPECS_PATTERN = 'spec/{acceptance,classes,defines,functions,types}/**/*_spec.rb'.freeze

RSpec::Core::RakeTask.new(:msm_module_spec) do |rspec|
  rspec.pattern = 'msm_module_spec.rb'
  rspec.ruby_opts = '-W0'
end

namespace :syntax do
  desc 'Check ruby files syntax (ruby -c)'
  task :ruby, [:module_path] do |syntax_ruby, args|
    Dir["#{args[:module_path]}/{lib,spec}/**/*.rb"].each do |rb|
      ruby '-c', rb
    end
  end

  desc 'Check metadata.json syntax (metadata-json-lint)'
  task :metadata_json, [:module_path] do |syntax_metadata_json, args|
    MetadataJsonLint.parse("#{args[:module_path]}/metadata.json")
  end

  desc 'Check manifests syntax'
  task :manifests, [:module_path] do |syntax_manifests, args|
    manifests = FileList["#{args[:module_path]}/manifests/**/*.pp"]
    manifests.reject! { |f| File.directory?(f) }
    output, has_errors = PuppetSyntax::Manifests.new.check(manifests)
    print "#{output.join("\n")}\n" unless output.empty?
    fail if has_errors || ( output.any? && PuppetSyntax.fail_on_deprecation_notices )
  end

  desc 'Check templates syntax'
  task :templates, [:module_path] do |syntax_templates, args|
    templates = FileList["#{args[:module_path]}/templates/**/*.{erb,epp}"]
    templates.reject! { |f| File.directory?(f) }
    errors = PuppetSyntax::Templates.new.check(templates)
    fail errors.join("\n") unless errors.empty?
  end

  desc 'Check hieradata syntax'
  task :hieradata, [:module_path, :hieradata_paths] do |syntax_hieradata, args|
    hieradata = FileList.new(args[:hieradata_paths])
    hieradata.reject! { |f| File.directory?(f) }
    errors = PuppetSyntax::Hiera.new.check(hieradata)
    fail errors.join("\n") unless errors.empty?
  end
end

desc 'Run all the syntax checks'
task :syntax, [:module_path, :hieradata_paths] do |syntax, args|
  args.with_defaults ARGS_DEFAULTS
  [:'syntax:ruby',
   :'syntax:metadata_json',
   :'syntax:manifests',
   :'syntax:templates'].each do |name|
    Rake::Task[name].invoke(args[:module_path])
  end
  hieradata = :'syntax:hieradata'
  Rake::Task[hieradata].invoke(args[:module_path], args[:hieradata_paths])
end

task :puppet_lint, [:module_path] do |puppet_lint, args|
  PuppetLint.configuration.disable_80chars
  PuppetLint.configuration.disable_140chars
  PuppetLint.configuration.relative = true
  PuppetLint.configuration.fail_on_warnings = true
  PuppetLint.configuration.error_level = :all
  PuppetLint.configuration.log_format = '%{path}: %{kind}: %{message}'
  PuppetLint.configuration.show_ignored = true
  PuppetLint.configuration.with_context = true
  manifests = FileList["#{args[:module_path]}/manifests/**/*.pp"]
  manifests = manifests.exclude("#{args[:module_path]}/bundle/**/*.pp",
                                "#{args[:module_path]}/pkg/**/*.pp",
                                "#{args[:module_path]}/spec/**/*.pp",
                                "#{args[:module_path]}/tests/**/*.pp",
                                "#{args[:module_path]}/types/**/*.pp",
                                "#{args[:module_path]}/vendor/**/*.pp")
  linter = PuppetLint.new
  manifests.to_a.each do |manifest|
    linter.file = manifest
    linter.run
    linter.print_problems
    abort if linter.errors? || (
      linter.warnings? && PuppetLint.configuration.fail_on_warnings
    )
  end
end

RuboCop::RakeTask.new :rubocop, [:module_path] do |rubocop, args|
  args.with_defaults ARGS_DEFAULTS
  rubocop.patterns = ["#{args[:module_path]}/{Gemfile,Rakefile,*.gemspec}",
                      "#{args[:module_path]}/lib/**/*.rb",
                      "#{args[:module_path]}/#{SPECS_PATTERN}"]
  rubocop.options = %w(--display-cop-names --display-style-guide
                       --extra-details --color)
end

desc 'Run all linters'
task :lint, [:module_path] do |lint, args|
  args.with_defaults ARGS_DEFAULTS
  Rake::Task[:rubocop].invoke(args[:module_path])
  Rake::Task[:puppet_lint].invoke(args[:module_path])
end

task :validate, [:module_path, :hieradata_paths] do |validate, args|
  args.with_defaults ARGS_DEFAULTS
  Rake::Task[:syntax].invoke(args[:module_path], args[:hieradata_paths])
  Rake::Task[:lint].invoke(args[:module_path])
end
