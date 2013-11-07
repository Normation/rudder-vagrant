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

## Config stage

YUM_ARGS="-y --nogpgcheck"

# Rudder related parameters
SERVER_INSTANCE_HOST="server.rudder.local"
DEMOSAMPLE="no"
LDAPRESET="yes"
INITPRORESET="yes"
ALLOWEDNETWORK[0]='192.168.42.0/24'

# Showtime
# Editing anything below might create a time paradox which would
# destroy the very fabric of our reality and maybe hurt kittens.
# Be responsible, please think of the kittens.

# Host preparation:
# This machine is "server", with the FQDN "server.rudder.local".
# It has this IP : 192.168.42.10 (See the Vagrantfile)

sed -ri "s/^127\.0\.0\.1[\t ]+server(.*)$/127\.0\.0\.1\tserver\.rudder\.local\1/" /etc/hosts
echo -e "\n192.168.42.11	node1.rudder.local" >> /etc/hosts
echo -e "\n192.168.42.12	node2.rudder.local" >> /etc/hosts
echo -e "\n192.168.42.13	node3.rudder.local" >> /etc/hosts
echo -e "\n192.168.42.14	node4.rudder.local" >> /etc/hosts
echo -e "\n192.168.42.15	node5.rudder.local" >> /etc/hosts
echo -e "\n192.168.42.16	node6.rudder.local" >> /etc/hosts
echo -e "\n192.168.42.17	node7.rudder.local" >> /etc/hosts
echo -e "\n192.168.42.18	node8.rudder.local" >> /etc/hosts
echo -e "\n192.168.42.19	node9.rudder.local" >> /etc/hosts
echo -e "\n192.168.42.20	node10.rudder.local" >> /etc/hosts
sed -ri 's#^HOSTNAME=.*#HOSTNAME=server#' /etc/sysconfig/network
hostname server


# Add Rudder repositories
for RUDDER_VERSION in 2.8
do
	if [ "${RUDDER_VERSION}" == "2.8" ]; then
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
setenforce 0
service iptables stop

# Refresh zypper
yum ${YUM_ARGS} check-update

# Install Rudder
yum ${YUM_ARGS} install rudder-server-root

# Initialize Rudder
/opt/rudder/bin/rudder-init.sh $SERVER_INSTANCE_HOST $DEMOSAMPLE $LDAPRESET $INITPRORESET ${ALLOWEDNETWORK[0]} < /dev/null > /dev/null 2>&1

echo "Rudder server install: FINISHED" |tee /tmp/rudder.log
