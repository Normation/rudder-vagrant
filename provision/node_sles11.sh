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
RUDDER_VERSION="2.6-nightly"

# Fetch parameters
RUDDER_REPO_URL="http://www.rudder-project.org/rpm-2.6-nightly/SLES_11_SP1/"

ZYPPER_ARGS="--non-interactive --no-gpg-checks"

# Showtime
# Editing anything below might create a time paradox which would
# destroy the very fabric of our reality and maybe hurt kittens.
# Be responsible, please think of the kittens.

# Host preparation:
# This machine is "node", with the FQDN "node.rudder.local".
# It has this IP : 192.168.42.11 (See the Vagrantfile)

echo "node1" > /etc/HOSTNAME
sed -i ""s%^127\.0\.1\.1.*%127\.0\.1\.1\\t$(cat /etc/hostname)\.rudder\.local\\t$(cat /etc/hostname)%"" /etc/hosts
echo -e "\n192.168.42.10	server.rudder.local" >> /etc/hosts

cat > /etc/zypp/repos.d/Rudder.repo <<EOF
[Rudder${RUDDER_VERSION}Nightly]
name=Rudder ${RUDDER_VERSION} Nightly RPM
enabled=1
autorefresh=0
baseurl=${RUDDER_REPO_URL}
type=rpm-md
keeppackages=0
EOF

# Add Rudder repository
cat > /etc/zypp/repos.d/Rudder2.6-nightly.repo <<EOF
[Rudder${RUDDER_VERSION26_NIGHTLY}Nightly]
name=Rudder ${RUDDER_VERSION26_NIGHTLY} Nightly RPM
enabled=0
autorefresh=0
baseurl=${RUDDER_REPO_URL26_NIGHTLY}
type=rpm-md
keeppackages=0
EOF

# Add Sles 11 repository
cat > /etc/zypp/repos.d/SUSE-SP1.repo <<EOF
[SUSE_SLES-11_SP1]
name=Official released updates for SUSE Linux Enterprise 11 SP1
type=yast2
baseurl=http://support.ednet.ns.ca/sles/11x86_64/
gpgcheck=1
gpgkey=http://support.ednet.ns.ca/sles/11x86_64/pubring.gpg
enabled=1
EOF

# Refresh Zypper
zypper ${ZYPPER_ARGS} refresh

# Install Rudder agent
zypper ${ZYPPER_ARGS} install rudder-agent

# Set the IP of the rudder master
echo "192.168.42.10" > /var/rudder/cfengine-community/policy_server.dat

# Start the CFEngine agent
/etc/init.d/rudder-agent start

echo "Rudder node install: FINISHED" |tee /tmp/rudder.log
