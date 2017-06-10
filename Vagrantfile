# -*- mode: ruby -*-
# vi: set ft=ruby :

#####################################################################################
# Copyright 2016 Normation SAS
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


Vagrant.configure("2") do |config|

  config.vm.define "server" do |server|
    server.vm.box = "ubuntu/xenial64"
    server.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1536"]
    end
    server.vm.provision :shell, :path => "repo.sh"
    server.vm.provision :shell, :path => "server.sh"
    server.vm.network :private_network, ip: "192.168.42.10"
    server.vm.hostname = "server.rudder.local"
    server.vm.network :forwarded_port, guest: 443, host: 8081
  end

  config.vm.define "node" do |node|
    node.vm.box = "ubuntu/xenial64"
    node.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "256"]
    end
    node.vm.provision :shell, :path => "repo.sh"
    node.vm.provision :shell, :path => "node.sh"
    node.vm.network :private_network, ip: "192.168.42.11"
    node.vm.hostname = "node.rudder.local"
  end

end

