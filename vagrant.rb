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

# find more : https://atlas.hashicorp.com/boxes/search
$centos5 = "hfm4/centos5"
$centos6 = "geerlingguy/centos6"
$centos6x32 = "bento/centos-6.7-i386"
$centos7 = "geerlingguy/centos7"

$fedora18 = "boxcutter/fedora18"

$oracle6 = "kikitux/oracle6"

$sles11 = "idar/sles11sp3"
$sles12 = "alchemy-solutions/sles12sp1"

$debian5 = "felipelavinz/debian-lenny"
$debian6 = "puppetlabs/debian-6.0.10-64-nocm"
$debian7 = "cargomedia/debian-7-amd64-default"
$debian8 = "oar-team/debian8"

$ubuntu10_04 = "bento/ubuntu-10.04"
$ubuntu12_04 = "ubuntu/precise64"
$ubuntu12_10 = "chef/ubuntu-12.10"
#$ubuntu14_04 = "ubuntu/trusty64"
$ubuntu14_04 = "normation/ubuntu-14.04"
$ubuntu16_04 = "ubuntu/xenial64"

$slackware14 = "ratfactor/slackware"

$solaris10 = "uncompiled/solaris-10"
#$solaris10 = "tnarik/solaris10-minimal"
$solaris11 = "ruby-concurrency/oracle-solaris-11"

$windows7 = "designerror/windows-7"
#$windows2008 = "opentable/win-2008r2-standard-amd64-nocm"
#$windows2008 = "ferventcoder/win2008r2-x64-nocm"
$windows2008 = "opentable/win-2008-enterprise-amd64-nocm"
$windows2012r2 = "opentable/win-2012r2-standard-amd64-nocm"

# Format pf_name => { 'pf_id' => 0, 'last_host_id' => 0, 'host_list' => [ 'host1', 'host2' ] }
$platforms = {
}
$last_pf_id = 0

def configure_box(config, os, pf_name, host_name, 
                  setup:'empty', version:nil, server:'', host_list:'',
                  windows_plugin:false, advanced_reporting:false,
                  ncf_version:nil, cfengine_version:nil, ram:nil
                 )
  pf = $platforms.fetch(pf_name) { |key| 
                                   $last_pf_id = $last_pf_id+1
                                   { 'pf_id' => $last_pf_id-1, 'host_list' => [ ]}
                                 }
  # autodetect platform id and host id
  pf_id = pf['pf_id']
  host_id = pf['host_list'].length
  pf['host_list'].push(host_name)
  host_list = host_list + " "
  $platforms[pf_name] = pf
  configure(config, os, pf_name, pf_id, host_name, host_id, 
            setup:setup, version:version, server:server, host_list:host_list,
            windows_plugin:windows_plugin, advanced_reporting:advanced_reporting,
            ncf_version:ncf_version, cfengine_version:cfengine_version, ram:ram)
end

# keep this function separate for compatibility with older Vagrantfiles
def configure(config, os, pf_name, pf_id, host_name, host_id, 
              setup:'empty', version:nil, server:'', host_list:'', 
              windows_plugin:false, advanced_reporting:false,
              ncf_version:nil, cfengine_version:nil, ram:nil
             )
  # Parameters
  dev = false
  if setup == "dev-server"
    setup = "server"
    dev = true
  end
  if setup == "server" then
    memory = 1536
    if windows_plugin then
      memory += 512
    end
    if advanced_reporting then
      memory += 512
    end
  elsif os == $windows7 or os == $windows2008 then
    memory = 512
  elsif os == $solaris10 or os == $solaris11 then
    memory = 1024
  else
    memory = 256
  end
  # override allocated ram
  unless ram.nil?
    memory = ram
  end
  memory = memory.to_s
  name = pf_name + "_" + host_name
  net = "192.168." + (pf_id+40).to_s
  ip = net + "." + (host_id+2).to_s
  forward = 100*(80+pf_id)+80

  # provisioning script
  if os == $windows7 or os == $windows2008 then
    command = "c:/vagrant/scripts/network.cmd #{net} @host_list@\n"
    if setup != "empty" and setup != "ncf" then
      command += "mkdir \"c:/Program Files/Cfengine\"\n"
      command += "echo #{server} > \"c:/Program Files/Cfengine/policy_server.dat\"\n"
      command += "c:/vagrant/rudder-plugins/Rudder-agent-x64.exe /S\n"
    end
  else
    command = "/vagrant/scripts/cleanbox.sh\n"
    command += "/vagrant/scripts/network.sh #{net} \"@host_list@\"\n"
    if setup != "empty" and setup != "ncf" then
      command += "ALLOWEDNETWORK=#{net}.0/24 /usr/local/bin/rudder-setup setup-#{setup} \"#{version}\" \"#{server}\"\n"
    end
    if setup == "ncf" then
      command += "/usr/local/bin/ncf-setup setup-local \"#{ncf_version}\" \"#{cfengine_version}\"\n"
    end
    if setup == "server" then
      command += "/vagrant/scripts/create-token\n"
      if windows_plugin then
        command += "/usr/local/bin/rudder-setup windows-plugin /vagrant/rudder-plugins/rudder-plugin-windows-server.zip\n"
      end
      if advanced_reporting then
        command += "/usr/local/bin/rudder-setup reporting-plugin /vagrant/rudder-plugins/advanced-reporting.tgz\n"
      end
    end
    if dev then
      command += "/vagrant/scripts/dev.sh\n"
    end
  end

  # Configure
  config.vm.define (name).to_sym do |server_config|
    server_config.vm.box = os
    server_config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", memory]
    end
    server_config.vm.provider :libvirt do |vm|
      vm.memory = memory
    end
    if setup == "server" then
      server_config.vm.network :forwarded_port, guest: 80, host: forward
      server_config.vm.network :forwarded_port, guest: 443, host: forward+1
    end
    if dev then
      server_config.vm.network :forwarded_port, guest: 389, host: 1389
      server_config.vm.network :forwarded_port, guest: 5432, host: 15432

      config.vm.synced_folder "/var/rudder/share", "/var/rudder/share", :create => true
      config.vm.synced_folder "/var/rudder/cfengine-community/inputs", "/var/rudder/cfengine-community/inputs", :create => true
    end
    server_config.vm.network :private_network, ip: ip
    server_config.vm.hostname = host_name
    # this is lazy evaluated and so will contain the last definition of host list
    host_list = $platforms[pf_name]['host_list'].join(" ") + " " + host_list
    server_config.vm.provision :shell, :inline => command.sub("@host_list@", host_list)
  end
end

