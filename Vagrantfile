# -*- mode: ruby -*-
# vi: set ft=ruby :

#####################################################################################
# Copyright 2012 Normation SAS
#####################################################################################
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, Version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#####################################################################################

Vagrant::Config.run do |config|

  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "debian-squeeze-64"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://dl.dropbox.com/u/937870/VMs/squeeze64.box"

  # Boot with a GUI so you can see the screen. (Default is headless)
  # config.vm.boot_mode = :gui

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  # config.vm.share_folder "v-data", "/vagrant_data", "../data"


  # Debian boxes
  config.vm.define :server do |server_config|
    server_config.vm.customize ["modifyvm", :id, "--memory", "1024"]
    server_config.vm.forward_port  80, 8080
    server_config.vm.network :hostonly, "192.168.42.10"
    server_config.vm.provision :shell, :path => "provision/server.sh"
  end

  config.vm.define :node1 do |node_config|
    node_config.vm.network :hostonly, "192.168.42.11"
    node_config.vm.host_name = "node1"
    node_config.vm.provision :shell, :path => "provision/node.sh"
  end

  config.vm.define :node2 do |node_config|
    node_config.vm.network :hostonly, "192.168.42.12"
    node_config.vm.host_name = "node2"
    node_config.vm.provision :shell, :path => "provision/node.sh"
  end

  config.vm.define :node3 do |node_config|
    node_config.vm.network :hostonly, "192.168.42.13"
    node_config.vm.host_name = "node3"
    node_config.vm.provision :shell, :path => "provision/node.sh"
  end

  # SLES 11 SP1 boxes
  config.vm.define :server_sles11 do |server_config|
    config.vm.box = "sles-11-64"
    config.vm.box_url = "http://puppetlabs.s3.amazonaws.com/pub/sles11sp1_64.box"
    server_config.vm.customize ["modifyvm", :id, "--memory", "1024"]
    server_config.vm.forward_port  80, 8080
    server_config.vm.network :hostonly, "192.168.42.10"
    server_config.vm.provision :shell, :path => "provision/server_sles11.sh"
  end

  config.vm.define :node1_sles11 do |node_config|
    config.vm.box = "sles-11-64"
    config.vm.box_url = "http://puppetlabs.s3.amazonaws.com/pub/sles11sp1_64.box"
    node_config.vm.network :hostonly, "192.168.42.11"
    node_config.vm.host_name = "node1"
    node_config.vm.provision :shell, :path => "provision/node_sles11.sh"
  end


end
