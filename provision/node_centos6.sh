#!/bin/bash
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

## Config stage


YUM_ARGS="-y --nogpgcheck"

# Showtime
# Editing anything below might create a time paradox which would
# destroy the very fabric of our reality and maybe hurt kittens.
# Be responsible, please think of the kittens.

# Host preparation:
# This machine is "node", with the FQDN "node.rudder.local".
# It has this IP : 192.168.42.11 (See the Vagrantfile)

echo "node" > /etc/hostname
sed -i ""s%^127\.0\.1\.1.*%127\.0\.1\.1\\t$(cat /etc/hostname)\.rudder\.local\\t$(cat /etc/hostname)%"" /etc/hosts
echo -e "\n192.168.42.10	server.rudder.local" >> /etc/hosts

# Add Rudder stable repository
echo "[Rudder_Stable]
name=Rudder stable Repository
baseurl=http://www.rudder-project.org/rpm-stable/RHEL_6/
enabled=1
gpgcheck=0
" > /etc/yum.repos.d/rudder_stable.repo

# Add Rudder latest repository
echo "[Rudder_Latest]
name=Rudder latest Repository
baseurl=http://www.rudder-project.org/rpm-latest/RHEL_6/
enabled=0
gpgcheck=0
" > /etc/yum.repos.d/rudder_latest.repo


# Set SElinux as permissive
setenforce 0
service iptables stop

# Refresh zypper
yum ${YUM_ARGS} check-update

# Install Rudder
yum ${YUM_ARGS} install rudder-agent

# Set the IP of the rudder master
echo "192.168.42.10" > /var/rudder/cfengine-community/policy_server.dat

# Start the CFEngine agent
/etc/init.d/rudder-agent restart

echo "Rudder node install: FINISHED" |tee /tmp/rudder.log
