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

ZYPPER_ARGS="--non-interactive --no-gpg-checks"

# Showtime
# Editing anything below might create a time paradox which would
# destroy the very fabric of our reality and maybe hurt kittens.
# Be responsible, please think of the kittens.

# Host preparation:
# This machine is "node", with the FQDN "node.rudder.local".
# It has this IP : 192.168.42.11 (See the Vagrantfile)

sed -ri "s/^127\.0\.0\.1[\t ]+(node[0-9]+)(.*)/127\.0\.0\.1\\t\1\.rudder\.local\2/" /etc/hosts
echo -e "\n192.168.42.10	server.rudder.local" >> /etc/hosts

# Add Rudder repositories
for RUDDER_VERSION in 2.10
do
    if [ "${RUDDER_VERSION}" == "2.10" ]; then
        ENABLED=1
    else
        ENABLED=0
    fi
    echo "[Rudder${RUDDER_VERSION}]
name=Rudder ${RUDDER_VERSION} RPM
enabled=${ENABLED}
autorefresh=0
baseurl=http://www.rudder-project.org/rpm-${RUDDER_VERSION}/SLES_11_SP1
type=rpm-md
keeppackages=0
" > /etc/zypp/repos.d/rudder${RUDDER_VERSION}.repo
done

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
