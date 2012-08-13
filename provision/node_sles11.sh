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

# Rudder version
RUDDER_VERSION="2.5"

# Fetch parameters
RUDDER_REPO_URL="http://www.rudder-project.org/rpm-2.5/SLES_11_SP1"
ZYPPER_ARGS="--non-interactive --no-gpg-checks"

# Showtime
# Editing anything below might create a time paradox which would
# destroy the very fabric of our reality and maybe hurt kittens.
# Be responsible, please think of the kittens.

# Host preparation:
# This machine is "node", with the FQDN "node.rudder.local".
# It has this IP : 192.168.42.11 (See the Vagrantfile)

sed -i "s%^127\.0\.0\.1.*%127\.0\.0\.1\tnode\.rudder\.local\tnode%" /etc/hosts
echo -e "\n192.168.42.10	server.rudder.local" >> /etc/hosts
echo "node" > /etc/HOSTNAME
hostname node

cat > /etc/zypp/repos.d/Rudder.repo <<EOF
[Rudder${RUDDER_VERSION}Nightly]
name=Rudder ${RUDDER_VERSION} Nightly RPM
enabled=1
autorefresh=0
baseurl=${RUDDER_REPO_URL}
type=rpm-md
keeppackages=0
EOF

# Update APT cache
zypper ${ZYPPER_ARGS} refresh

#Packages required by Rudder
zypper ${ZYPPER_ARGS} install rudder-agent

# Set the IP of the rudder master
echo "192.168.42.10" > /var/rudder/cfengine-community/policy_server.dat

# Start the CFEngine agent
/etc/init.d/rudder-agent start

echo "Rudder node install: FINISHED" |tee /tmp/rudder.log
