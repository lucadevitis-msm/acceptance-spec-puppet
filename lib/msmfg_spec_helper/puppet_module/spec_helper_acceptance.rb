require 'beaker-rspec'

RSpec.configure do |hook|
  hook.before :suite do
    hosts.each do |host|
      install_dev_puppet_module_on host, source: '.'
      # on host, 'puppet module install puppetlabs-stdlib'
    end
  end
end
