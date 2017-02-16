require 'msmfg_spec_helper/puppet_module'
require 'rake'

PUPPET_MODULE = MSMFGSpecHelper::PuppetModule.new

# Creates all the `directory` tasks
PUPPET_MODULE.directories.each do |path|
  file path do |dir|
    include MSMFGSpecHelper::LoggerMixIn
    logger.info("Creating #{dir.name} ...")
    mkdir_p dir.name, verbose: false
  end
end

# Creates all the `file` tasks
PUPPET_MODULE.files.each do |item|
  dirname = File.dirname(item[:name])

  requires = item[:requires].to_a
  requires << dirname unless dirname == '.'

  desc "Creates #{item[:name]}"
  file item[:name] => requires do |file|
    item[:create].call(file)
  end
end
