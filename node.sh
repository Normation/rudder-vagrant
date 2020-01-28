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

# Make sure we don't run interactive commands
export DEBIAN_FRONTEND=noninteractive

/usr/local/bin/rudder-setup setup-agent "latest" "server.rudder.local"


# Setup server hostname 
echo "server.rudder.local" > /var/rudder/cfengine-community/policy_server.dat

# Send an inventory
rudder agent inventory


echo "Rudder node install: FINISHED" |tee rudder-install.log
