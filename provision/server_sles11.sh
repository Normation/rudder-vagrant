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

ZYPPER_ARGS="--non-interactive --no-gpg-checks"

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

sed -i "s%^127\.0\.0\.1.*%127\.0\.0\.1\tserver\.rudder\.local\tserver%" /etc/hosts
echo -e "\n192.168.42.11	node.rudder.local" >> /etc/hosts
echo -e "\n192.168.42.12	node2.rudder.local" >> /etc/hosts
echo -e "\n192.168.42.13	node3.rudder.local" >> /etc/hosts
echo -e "\n192.168.42.14	node4.rudder.local" >> /etc/hosts
echo -e "\n192.168.42.15	node5.rudder.local" >> /etc/hosts
echo -e "\n192.168.42.16	node6.rudder.local" >> /etc/hosts
echo -e "\n192.168.42.17	node7.rudder.local" >> /etc/hosts
echo -e "\n192.168.42.18	node8.rudder.local" >> /etc/hosts
echo -e "\n192.168.42.19	node9.rudder.local" >> /etc/hosts
echo -e "\n192.168.42.20	node10.rudder.local" >> /etc/hosts
echo "server" > /etc/HOSTNAME
hostname server

# Add Rudder repositories
for RUDDER_VERSION in 2.8
do
	if [ "${RUDDER_VERSION}" == "2.8" ]; then
		ENABLED=1
    else
    	ENABLED=0
    fi
    echo "[Rudder${RUDDER_VERSION}]
name=Rudder ${RUDDER_VERSION} RPM
enabled=${ENABLED}
autorefresh=0
baseurl=http://www.rudder-project.org/rpm-${RUDDER_VERSION}/SLES_11_SP1/
type=rpm-md
keeppackages=0
" > /etc/zypp/repos.d/rudder${RUDDER_VERSION}.repo
done

# Add Sles 11 repositories
cat > /etc/zypp/repos.d/SUSE-SP1.repo <<EOF
[SUSE_SLES-11_SP1]
name=Official released updates for SUSE Linux Enterprise 11 SP1
type=yast2
baseurl=http://support.ednet.ns.ca/sles/11x86_64/
gpgcheck=1
gpgkey=http://support.ednet.ns.ca/sles/11x86_64/pubring.gpg
enabled=1
EOF
cat > /etc/zypp/repos.d/SUSE_SLE-11_SP1_SDK.repo <<EOF
[SUSE_SLE-11_SP1_SDK]
name=Official SUSE Linux Enterprise 11 SP1 SDK
type=yast2
baseurl=http://support.ednet.ns.ca/sles/SLE-11-SP1-SDK-x86_64/
enabled=1
autorefresh=0
keeppackages=0
EOF

# Remove DVD repository
zypper rr "SUSE-Linux-Enterprise-Server-11-SP1 11.1.1-1.152"

# Refresh zypper
zypper ${ZYPPER_ARGS} refresh

# Install Rudder
zypper ${ZYPPER_ARGS} install rudder-server-root

# Initialize Rudder
/opt/rudder/bin/rudder-init.sh $SERVER_INSTANCE_HOST $DEMOSAMPLE $LDAPRESET $INITPRORESET ${ALLOWEDNETWORK[0]} < /dev/null > /dev/null 2>&1

# Edit the base url parameter of Rudder to this Vagrant machine fully qualified name no need for 2.5
# sed -i s%^base\.url\=.*%base\.url\=http\:\/\/server\.rudder\.local\:8080\/rudder% /opt/rudder/etc/rudder-web.properties

# Add licenses (don't think it's needed anymore)
# cp licenses.xml /opt/rudder/etc/licenses/

# Start the rudder web service
/etc/init.d/jetty restart < /dev/null > /dev/null 2>&1

# Start the CFEngine backend
/etc/init.d/rudder-agent restart

echo "Rudder server install: FINISHED" |tee /tmp/rudder.log
