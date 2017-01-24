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

def module_path(args)
  args[:module_path] || '.'
end

def file_list(args, pattern, *exclude)
  path = module_path(args)
  unwanted = exclude.map {|f| "#{path}/#{f}"}
  FileList["#{path}/#{pattern}"].tap do |list|
    list.exclude(*unwanted).reject {|f| File.directory? f}
  end
end

def ruby_files(args)
  file_list(args, "**/{*.rb,{Gem,Rake}file,{,*}.gemspec}",
                  "bundle/**/*",         # bundler
                  "vendor/**/*",         # bundler
                  "pkg/**/*",            # gem build process
                  "spec/fixtures/**/*")  # puppetlabs fixtures
end

def manifests(args)
  file_list(args, "{manifests,puppet/}/**/*.pp")
end

def templates(args)
  file_list(args, "{templates,puppet/modules}/**/*.{erb,epp}")
end

def hieradata(args)
  file_list(args, "{,puppet/}{,hiera}data/**/*.{yml,yaml,eyaml}")
end

namespace :syntax do
  desc 'Check ruby files syntax (ruby -c)'
  task :ruby, [:module_path] do |_, args|
    puts '  Checking ruby files...'
    ruby_files.each { |ruby_file| ruby '-c', ruby_file }
  end

  desc 'Check metadata.json syntax (metadata-json-lint)'
  task :metadata_json, [:module_path] do |_, args|
    puts '  Checking metadata.json...'
    MetadataJsonLint.parse("#{module_path(args)}/metadata.json")
  end

  desc 'Check puppet manifests syntax...'
  task :manifests, [:module_path] do |_, args|
    puts '  Checking puppet manifests'
    output, has_errors = PuppetSyntax::Manifests.new.check(manifests(args))
    print "#{output.join("\n")}\n" unless output.empty?
    fail if has_errors || output.any?
  end

  desc 'Check templates syntax'
  task :templates, [:module_path] do |_, args|
    puts '  Checking templates...'
    errors = PuppetSyntax::Templates.new.check(templates(args))
    fail errors.join("\n") unless errors.empty?
  end

  desc 'Check hieradata syntax'
  task :hieradata, [:module_path] do |_, args|
    puts '  Checking hieradata files...'
    errors = PuppetSyntax::Hiera.new.check(hieradata(args))
    fail errors.join("\n") unless errors.empty?
  end

  task :all, [:module_path] => [:ruby,
                                :metadata_json,
                                :manifests,
                                :templates,
                                :hieradata]
end

desc 'Run all the syntax checks'
task :syntax, [:module_path] do |_, args|
  puts 'Checking syntax...'
  Rake::Task[:'syntax:all'].invoke(args[:module_path])
end

desc 'Check the module against MSMFG acceptance specs'
RSpec::Core::RakeTask.new(:module_spec, [:module_path]) do |rspec, args|
  pattern = File.join(Gem.datadir('msmfg_spec_helper'), 'module_spec.rb')
  rspec.pattern = pattern
  rspec.ruby_opts = "-W0 -C#{module_path(args)}"
  rspec.rspec_opts = "--color --documentation"
  rspec.verbose = false
end

task :puppet_lint, [:module_path] do |_, args|
  PuppetLint.configuration.disable_80chars
  PuppetLint.configuration.disable_140chars
  PuppetLint.configuration.relative = true
  # PuppetLint.configuration.fail_on_warnings = true
  PuppetLint.configuration.error_level = :all
  PuppetLint.configuration.log_format = '%{path}: %{kind}: %{message}'
  PuppetLint.configuration.show_ignored = true
  PuppetLint.configuration.with_context = true

  linter = PuppetLint.new
  manifests(args).each do |manifest|
    linter.file = manifest
    linter.run
    linter.print_problems
    fail if linter.errors? || linter.warnings?
  end
end

RuboCop::RakeTask.new :rubocop, [:module_path] => [:module_spec] do |rc, args|
  rc.patterns = ruby_files(args)
  config = File.join(Gem.datadir('msmfg_spec_helper'), 'rubocop.yml')
  rc.options = %W(--config #{config}
                  --display-cop-names
                  --display-style-guide
                  --extra-details
                  --color)
end

desc 'Run syntax check, module spec and linters'
task :validate, [:module_path] => [:syntax, :module_spec, :rubocop, :puppet_lint]
