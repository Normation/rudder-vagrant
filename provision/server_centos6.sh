#!/bin/bash
#####################################################################################
# Copyright 2013 Normation SAS
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

YUM_ARGS="-y"

# Rudder related parameters
SERVER_INSTANCE_HOST="server.rudder.local"
DEMOSAMPLE="no"
LDAPRESET="yes"
INITPRORESET="yes"
ALLOWEDNETWORK[0]='192.168.42.0/24'

# Host preparation:
# This machine is "server", with the FQDN "server.rudder.local".
# It has this IP : 192.168.42.10 (See the Vagrantfile)
# Install a clean /etc/hosts for Rudder to operate properly (all)
cat << EOF > /etc/hosts

# IPv4
127.0.0.1       localhost server server.rudder.local
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.42.10   server.rudder.local server
192.168.42.11   node1.rudder.local node1
192.168.42.12   node2.rudder.local node2
192.168.42.13   node3.rudder.local node3
192.168.42.14   node4.rudder.local node4
192.168.42.15   node5.rudder.local node5
192.168.42.16   node6.rudder.local node6
192.168.42.17   node7.rudder.local node7
192.168.42.18   node8.rudder.local node8
192.168.42.19   node9.rudder.local node9
192.168.42.20   node10.rudder.local node10
EOF


sed -ri 's#^HOSTNAME=.*#HOSTNAME=server#' /etc/sysconfig/network
hostname server

# Add Rudder repositories
for RUDDER_VERSION in latest
do
    if [ "${RUDDER_VERSION}" == "latest" ]; then
        ENABLED=1
    else
        ENABLED=0
    fi
    echo "[Rudder_${RUDDER_VERSION}]
name=Rudder ${RUDDER_VERSION} Repository
baseurl=http://www.rudder-project.org/rpm-${RUDDER_VERSION}/RHEL_6/
enabled=${ENABLED}
gpgcheck=1
gpgkey=http://www.rudder-project.org/rpm-${RUDDER_VERSION}/RHEL_6/repodata/repomd.xml.key
" > /etc/yum.repos.d/rudder${RUDDER_VERSION}.repo
done

# Set SElinux as permissive
setenforce 0 || true
service iptables stop

# Install Rudder
yum ${YUM_ARGS} install rudder-server-root

# Initialize Rudder
/opt/rudder/bin/rudder-init.sh $SERVER_INSTANCE_HOST $DEMOSAMPLE $LDAPRESET $INITPRORESET ${ALLOWEDNETWORK[0]} < /dev/null > /dev/null 2>&1

echo "Rudder server install: FINISHED" |tee /tmp/rudder.log
echo "You can now access the Rudder web interface on https://192.168.42.10/" |tee /tmp/rudder.log
