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

# Fetch parameters
KEYSERVER=keyserver.ubuntu.com
KEY=474A19E8

# Make sure we don't run interactive commands
export DEBIAN_FRONTEND=noninteractive

# Accept the Rudder repository key
wget --quiet -O- "https://${KEYSERVER}/pks/lookup?op=get&search=0x${KEY}" | apt-key add -

# Update APT cache
apt-get update

apt-get --assume-yes install lsb-release

# Add latest Rudder repository
echo "deb http://repository.rudder.io/apt/latest/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/rudder.list

# Update APT cache
apt-get update

# Configure name resolution
echo "192.168.42.10 server.rudder.local
192.168.42.11 node.rudder.local" >> /etc/hosts
