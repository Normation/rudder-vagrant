# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative 'vagrant.rb'

Vagrant.configure("2") do |config|
config.vm.provider 'virtualbox' do |v|
    v.linked_clone = true if Vagrant::VERSION =~ /^1.8/
end
if Vagrant.has_plugin?("vagrant-cachier")
  config.cache.scope = :box
end

# you can replace it with $centos7 or any other name available in the vagrant.rb file
system = $ubuntu14_04
# you can put any supported version here
version = '4.0'
# prefix for the box names
prefix = 'demo'

configure_box(config, system, prefix, 'server', setup:'server', version:version)
configure_box(config, system, prefix, 'agent1', setup:'agent', version:version, server:'server')
configure_box(config, system, prefix, 'agent2', setup:'agent', version:version, server:'server')

## Uncomment if you want a more complex setup
#configure_box(config, system, prefix, 'relay', setup:'relay', version:version, server:'server')
#configure_box(config, system, prefix, 'agent3', setup:'agent', version:version, server:'relay')
#configure_box(config, system, prefix, 'agent4', setup:'agent', version:version, server:'relay')

end
