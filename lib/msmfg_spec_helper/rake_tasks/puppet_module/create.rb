require 'msmfg_spec_helper/puppet_module'
require 'rake'

PUPPET_MODULE = MSMFGSpecHelper::PuppetModule.new

# Creates all the `directory` tasks
PUPPET_MODULE.directories.each do |path|
  file path do |dir|
    include MSMFGSpecHelper::LoggerMixIn
    begin
      mkdir_p dir.name, verbose: false
      logger.info("rake_task: puppet_module: directory: OK: #{dir.name}")
    rescue => e
      logger.info("rake_task: puppet_module: directory: KO: #{dir.name}: #{e}")
      raise
    end
  end
end

# Creates all the `file` tasks
PUPPET_MODULE.files.each do |item|
  dirname = File.dirname(item[:name])

  requires = item[:requires].to_a
  requires << dirname unless dirname == '.'

  desc "Creates #{item[:name]}"
  file item[:name] => requires do |file|
    include MSMFGSpecHelper::LoggerMixIn
    begin
      item[:create].call(file)
      logger.info("rake_task: puppet_module: file: OK: #{file.name}")
    rescue => e
      logger.info("rake_task: puppet_module: file: KO: #{file.name}: #{e}")
      raise
    end
  end
end
