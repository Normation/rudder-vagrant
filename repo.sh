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

SCRIPTS_PREFIX="/vagrant"
if [ "$1" != "" ]; then
  SCRIPTS_PREFIX=$1
fi

### THINGS TO DO ON AN ALREADY CLEAN BOX
if type curl >/dev/null 2>/dev/null
then
  curl -L -s -o /usr/local/bin/rudder-setup https://repository.rudder.io/tools/rudder-setup
else
  wget -q -O /usr/local/bin/rudder-setup https://repository.rudder.io/tools/rudder-setup
fi
chmod +x /usr/local/bin/rudder-setup

# Configure name resolution
echo "192.168.42.10 server.rudder.local
192.168.42.11 node.rudder.local" >> /etc/hosts
