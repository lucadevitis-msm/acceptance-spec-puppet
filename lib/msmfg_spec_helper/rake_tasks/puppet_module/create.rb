require 'msmfg_spec_helper/puppet_module'
require 'rake'

# Creates all the `directory` tasks
MSMFGSpecHelper::PuppetModule.directories.each do |path|
  logger = MSMFGSpecHelper::Logger.instance
  file path do |dir|
    begin
      mkdir_p dir.name, verbose: false
      logger.info("create: directory: #{dir.name}")
    rescue => e
      logger.error("create: directory: #{dir.name}: #{e}")
      raise
    end
  end
end

# Creates all the `file` tasks
MSMFGSpecHelper::PuppetModule.files.each do |item|
  logger = MSMFGSpecHelper::Logger.instance
  dirname = File.dirname(item[:name])

  requires = item[:requires].to_a
  requires << dirname unless dirname == '.'

  desc "Creates #{item[:name]}"
  file item[:name] => requires do |file|
    begin
      item[:create].call(file)
      logger.info("create: file: #{file.name}")
    rescue => e
      logger.error("create: file: #{file.name}: #{e}")
      raise
    end
  end
end
