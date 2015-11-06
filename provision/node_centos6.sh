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

set -e

## Config stage

YUM_ARGS="-y --nogpgcheck"

# Showtime
# Editing anything below might create a time paradox which would
# destroy the very fabric of our reality and maybe hurt kittens.
# Be responsible, please think of the kittens.

# Host preparation:
# This machine is "node", with the FQDN "node.rudder.local".
# It has this IP : 192.168.42.11 (See the Vagrantfile)

sed -ri "s/^127\.0\.0\.1[\t ]+(node[0-9]+)[\t ]+(.*)/127\.0\.0\.1\\t\1\.rudder\.local \2/" /etc/hosts
echo -e "\n192.168.42.10	server.rudder.local server" >> /etc/hosts
echo -e "\n192.168.42.11	node1.rudder.local node1" >> /etc/hosts
echo -e "\n192.168.42.12	node2.rudder.local node2" >> /etc/hosts
echo -e "\n192.168.42.13	node3.rudder.local node3" >> /etc/hosts
echo -e "\n192.168.42.14	node4.rudder.local node4" >> /etc/hosts
echo -e "\n192.168.42.15	node5.rudder.local node5" >> /etc/hosts
echo -e "\n192.168.42.16	node6.rudder.local node6" >> /etc/hosts
echo -e "\n192.168.42.17	node7.rudder.local node7" >> /etc/hosts
echo -e "\n192.168.42.18	node8.rudder.local node8" >> /etc/hosts
echo -e "\n192.168.42.19	node9.rudder.local node9" >> /etc/hosts
echo -e "\n192.168.42.20	node10.rudder.local node10" >> /etc/hosts

# Add Rudder repositories
for RUDDER_VERSION in latest; do
    if [ "${RUDDER_VERSION}" == "latest" ]; then
        ENABLED=1
    else
        ENABLED=0
    fi
    echo "[Rudder_${RUDDER_VERSION}]
name=Rudder ${RUDDER_VERSION} Repository
baseurl=http://www.rudder-project.org/rpm-${RUDDER_VERSION}/RHEL_6/
enabled=${ENABLED}
gpgcheck=0
" > /etc/yum.repos.d/rudder${RUDDER_VERSION}.repo
done


# Set SElinux as permissive
setenforce 0 || true
service iptables stop

# Refresh zypper
yum ${YUM_ARGS} check-update || true

# Install Rudder
yum ${YUM_ARGS} install rudder-agent

# Set the IP of the rudder master
echo "192.168.42.10" > /var/rudder/cfengine-community/policy_server.dat

# Start the CFEngine agent
/etc/init.d/rudder-agent restart

echo "Rudder node install: FINISHED" |tee /tmp/rudder.log
