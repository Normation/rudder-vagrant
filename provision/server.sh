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

# Fetch parameters
KEYSERVER=keyserver.ubuntu.com
KEY=474A19E8

# Rudder related parameters
SERVER_INSTANCE_HOST="server.rudder.local"
DEMOSAMPLE="no"
LDAPRESET="yes"
INITPRORESET="yes"
ALLOWEDNETWORK[0]='192.168.42.0/24'

# Misc
APTITUDE_ARGS="--assume-yes"

# Showtime
# Editing anything below might create a time paradox which would
# destroy the very fabric of our reality and maybe hurt kittens.
# Be responsible, please think of the kittens.

# Host preparation:
# This machine is "server", with the FQDN "server.rudder.local".
# It has this IP : 192.168.42.10 (See the Vagrantfile)

sed -i "s%^127\.0\.1\.1.*%127\.0\.1\.1\tserver\.rudder\.local\tserver%" /etc/hosts
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


# Install lsb-release so we can guess which Debian version are we operating on.
aptitude update && aptitude ${APTITUDE_ARGS} install lsb-release
DEBIAN_RELEASE=$(lsb_release -cs)

##Accept Java Licence
echo sun-java6-jre shared/accepted-sun-dlj-v1-1 select true | /usr/bin/debconf-set-selections

# Accept the Rudder repository key
wget --quiet -O- "http://${KEYSERVER}/pks/lookup?op=get&search=0x${KEY}" | sudo apt-key add -

#APT configuration
echo "deb http://ftp.fr.debian.org/debian/ ${DEBIAN_RELEASE} main non-free" > /etc/apt/sources.list
echo "deb-src http://ftp.fr.debian.org/debian/ ${DEBIAN_RELEASE} main non-free" >> /etc/apt/sources.list
echo "deb http://security.debian.org/ ${DEBIAN_RELEASE}/updates main" >> /etc/apt/sources.list
echo "deb-src http://security.debian.org/ ${DEBIAN_RELEASE}/updates main" >> /etc/apt/sources.list
echo "deb http://ftp.fr.debian.org/debian/ ${DEBIAN_RELEASE}-updates main" >> /etc/apt/sources.list
echo "deb-src http://ftp.fr.debian.org/debian/ ${DEBIAN_RELEASE}-updates main" >> /etc/apt/sources.list

#Rudder repositories
for RUDDER_VERSION in 2.6 2.7 2.8
do
	if [ "${RUDDER_VERSION}" == "2.6" ]; then
		echo "deb http://www.rudder-project.org/apt-${RUDDER_VERSION}/ ${DEBIAN_RELEASE} main contrib non-free" > /etc/apt/sources.list.d/rudder.list
    else
		echo "#deb http://www.rudder-project.org/apt-${RUDDER_VERSION}/ ${DEBIAN_RELEASE} main contrib non-free" >> /etc/apt/sources.list.d/rudder.list
    fi
done

# Update APT cache
aptitude update

#Packages required by Rudder
aptitude ${APTITUDE_ARGS} install rudder-server-root

# Initialize Rudder
/opt/rudder/bin/rudder-init.sh $SERVER_INSTANCE_HOST $DEMOSAMPLE $LDAPRESET $INITPRORESET ${ALLOWEDNETWORK[0]} < /dev/null > /dev/null 2>&1

# Edit the base url parameter of Rudder to this Vagrant machine fully qualified name don't need for 2.5
# sed -i s%^base\.url\=.*%base\.url\=http\:\/\/server\.rudder\.local\:8080\/rudder% /opt/rudder/etc/rudder-web.properties

# Add licenses
cp licenses.xml /opt/rudder/etc/licenses/

# Start the rudder web service
/etc/init.d/jetty restart

# Start the CFEngine backend
/etc/init.d/cfengine-community restart

echo '0,5,10,15,20,25,30,35,40,45,50,55 * * * * root if [ `ps -efww | grep cf-execd | grep "/var/rudder/cfengine-community/bin/cf-execd" | grep -v grep | wc -l` -eq 0 ]; then /var/rudder/cfengine-community/bin/cf-execd; fi' >> /etc/crontab

# Set password to default passwords, if you need an easy access.
#if [ -e /opt/rudder/etc/rudder-passwords.conf ] ; then
#  sed -i "s/\(RUDDER_WEBDAV_PASSWORD:\).*/\1rudder/" /opt/rudder/etc/rudder-passwords.conf
#  sed -i "s/\(RUDDER_PSQL_PASSWORD:\).*/\1Normation/" /opt/rudder/etc/rudder-passwords.conf
#  sed -i "s/\(RUDDER_OPENLDAP_BIND_PASSWORD:\).*/\1secret/" /opt/rudder/etc/rudder-passwords.conf
#fi

# Run cf-agent to set passwords to default
/var/rudder/cfengine-community/bin/cf-agent

echo "Rudder server install: FINISHED" |tee /tmp/rudder.log
