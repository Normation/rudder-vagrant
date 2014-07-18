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

# Fetch parameters
KEYSERVER=keyserver.ubuntu.com
KEY=474A19E8

# Misc
APTITUDE_ARGS="--assume-yes"
export DEBIAN_FRONTEND=noninteractive

# Showtime
# Editing anything below might create a time paradox which would
# destroy the very fabric of our reality and maybe hurt kittens.
# Be responsible, please think of the kittens.

# Host preparation:
# This machine is "node", with the FQDN "node.rudder.local".
# It has this IP : 192.168.42.11 (See the Vagrantfile)

sed -ri "s/^127\.0\.1\.1[\t ]+(node[0-9]+)(.*)/127\.0\.1\.1\\t\1\.rudder\.local\2/" /etc/hosts
echo -e "\n192.168.42.10	server.rudder.local" >> /etc/hosts


# Install lsb-release so we can guess which Debian version are we operating on.
aptitude update && aptitude ${APTITUDE_ARGS} install lsb-release
DEBIAN_RELEASE=$(lsb_release -cs)

# Accept the Rudder repository key
wget --quiet -O- "http://${KEYSERVER}/pks/lookup?op=get&search=0x${KEY}" | sudo apt-key add -

#APT configuration
echo "deb http://ftp.fr.debian.org/debian/ ${DEBIAN_RELEASE} main non-free" > /etc/apt/sources.list
echo "deb-src http://ftp.fr.debian.org/debian/ ${DEBIAN_RELEASE} main non-free" >> /etc/apt/sources.list
echo "deb http://security.debian.org/ ${DEBIAN_RELEASE}/updates main" >> /etc/apt/sources.list
echo "deb-src http://security.debian.org/ ${DEBIAN_RELEASE}/updates main" >> /etc/apt/sources.list
echo "deb http://ftp.fr.debian.org/debian/ ${DEBIAN_RELEASE}-updates main" >> /etc/apt/sources.list
echo "deb-src http://ftp.fr.debian.org/debian/ ${DEBIAN_RELEASE}-updates main" >> /etc/apt/sources.list

# Rudder repositories
for RUDDER_VERSION in 2.10 2.11
do
    if [ "${RUDDER_VERSION}" == "2.10" ]; then
        echo "deb http://www.rudder-project.org/apt-${RUDDER_VERSION}/ ${DEBIAN_RELEASE} main contrib non-free" > /etc/apt/sources.list.d/rudder.list
    else
        echo "#deb http://www.rudder-project.org/apt-${RUDDER_VERSION}/ ${DEBIAN_RELEASE} main contrib non-free" >> /etc/apt/sources.list.d/rudder.list
    fi
done

# Update APT cache
aptitude update

#Packages required by Rudder
aptitude ${APTITUDE_ARGS} install rudder-agent

# Set the IP of the rudder master
echo "192.168.42.10" > /var/rudder/cfengine-community/policy_server.dat

# Start the CFEngine agent
/etc/init.d/rudder-agent start

echo "Rudder node install: FINISHED" |tee /tmp/rudder.log
