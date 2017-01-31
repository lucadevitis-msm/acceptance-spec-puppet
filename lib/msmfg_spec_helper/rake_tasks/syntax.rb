require 'metadata_json_lint'
require 'msmfg_spec_helper/rake_tasks/helpers'
require 'puppet-syntax'
require 'rake'

# rubocop:disable Metrics/BlockLength
namespace :syntax do
  include MSMFGSpecHelper::RakeTasks::Helpers

  desc 'Check ruby files syntax (ruby -c)'
  task :ruby do
    puts '  Checking ruby files syntax...'
    ruby_files.include('**/Puppetfile.*').each do |rb|
      sh "ruby -c #{rb} >/dev/null", verbose: false
    end
  end

  desc 'Check metadata.json syntax (metadata-json-lint)'
  task :metadata_json do
    puts '  Checking metadata.json syntax...'
    MetadataJsonLint.options[:strict_license] = false
    MetadataJsonLint.parse('metadata.json') if ::File.file? 'metadata.json'
  end

  desc 'Check puppet manifests syntax...'
  task :manifests do
    puts '  Checking puppet manifests syntax...'
    output, has_errors = PuppetSyntax::Manifests.new.check(manifests)
    puts output.join("\n") unless output.empty?
    abort if has_errors || output.any?
  end

  desc 'Check templates syntax'
  task :templates do
    puts '  Checking templates syntax...'
    errors = PuppetSyntax::Templates.new.check(templates)
    abort errors.join("\n") unless errors.empty?
  end

  desc 'Check hieradata syntax'
  task :hieradata do
    puts '  Checking hieradata files syntax...'
    errors = PuppetSyntax::Hiera.new.check(hieradata)
    abort errors.join("\n") unless errors.empty?
  end

  desc 'Check fragment syntax'
  task :fragments do
    puts '  Checking fragments files syntax...'
    errors = fragments.select do |fragment|
      begin
        YAML.safe_load(fragment) && nil
      rescue => e
        "ERROR: Failed to parse #{fragment}: #{e}"
      end
    end
    abort errors.compact.join("\n") if errors.any?
  end

  multitask all: [:'syntax:ruby',
                  :'syntax:metadata_json',
                  :'syntax:manifests',
                  :'syntax:templates',
                  :'syntax:hieradata',
                  :'syntax:fragments']
end
# rubocop:enable Metrics/BlockLength

desc 'Run all the syntax checks'
task :syntax do
  puts 'Checking syntax...'
  Rake::Task[:'syntax:all'].invoke
end
