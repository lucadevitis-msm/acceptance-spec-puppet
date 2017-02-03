require 'msmfg_spec_helper/module'
require 'rake'

MSMFG_MODULE = MSMFGSpecHelper::Module.new.freeze

MSMFG_MODULE.directories.each {|path| directory path}

MSMFG_MODULE.files.each do |item|
  dirname = File.dirname(item[:name])

  requires = item[:requires].to_a
  requires << dirname unless dirname == '.'

  desc "Creates #{item[:name]}"
  file item[:name] => requires, &item[:create]
end
