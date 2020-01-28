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
ALLOWEDNETWORK=192.168.42.0/24 /usr/local/bin/rudder-setup setup-server "latest"

echo "Rudder server install: FINISHED" |tee rudder-install.log
echo "You can now access the Rudder web interface on https://localhost:8081/" |tee rudder-install.log
