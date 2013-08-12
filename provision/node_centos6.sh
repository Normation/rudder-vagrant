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

# Rudder version
RUDDER_VERSION="2.6"
RUDDER_VERSION27="2.7"

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

# Add Rudder repository
echo "[Rudder_${RUDDER_VERSION}]
name=Rudder ${RUDDER_VERSION} Repository
baseurl=http://www.rudder-project.org/rpm-${RUDDER_VERSION}/RHEL_6/
enabled=1
gpgcheck=0
" > /etc/yum.repos.d/rudder.repo

# Add Rudder 2.7 repository
echo "[Rudder_${RUDDER_VERSION26_NIGHTLY}]
name=Rudder ${RUDDER_VERSION26_NIGHTLY} Repository
baseurl=http://www.rudder-project.org/rpm-${RUDDER_VERSION27}/RHEL_6/
enabled=0
gpgcheck=0
" > /etc/yum.repos.d/rudder2.7.repo
EOF



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
