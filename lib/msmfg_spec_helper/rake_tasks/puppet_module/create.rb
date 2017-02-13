require 'msmfg_spec_helper/puppet_module'
require 'rake'

PUPPET_MODULE = MSMFGSpecHelper::PuppetModule.new.freeze

# Creates all the `directory` tasks
PUPPET_MODULE.directories.each { |path| directory path }

# Creates all the `file` tasks
PUPPET_MODULE.files.each do |item|
  dirname = File.dirname(item[:name])

  requires = item[:requires].to_a
  requires << dirname unless dirname == '.'

  desc "Creates #{item[:name]}"
  file item[:name] => requires do |file|
    MSMFGSpecHelper::logger.info("Creating #{item[:name]} ...")
    item[:create].call(file)
  end
end
