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
RUDDER_REPO_URL="http://www.rudder-project.org/apt-2.4/"

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

aptitude update && aptitude ${APTITUDE_ARGS} install lsb-release

##Accept Java Licence
echo sun-java6-jre shared/accepted-sun-dlj-v1-1 select true | /usr/bin/debconf-set-selections

apt-key adv --recv-keys --keyserver ${KEYSERVER} ${KEY}

#APT configuration
echo "deb http://ftp.fr.debian.org/debian/ $(lsb_release -cs) main non-free" > /etc/apt/sources.list
echo "deb-src http://ftp.fr.debian.org/debian/ $(lsb_release -cs) main non-free" >> /etc/apt/sources.list
echo "deb http://security.debian.org/ $(lsb_release -cs)/updates main" >> /etc/apt/sources.list
echo "deb-src http://security.debian.org/ $(lsb_release -cs)/updates main" >> /etc/apt/sources.list
echo "deb http://ftp.fr.debian.org/debian/ $(lsb_release -cs)-updates main" >> /etc/apt/sources.list
echo "deb-src http://ftp.fr.debian.org/debian/ $(lsb_release -cs)-updates main" >> /etc/apt/sources.list

echo "deb ${RUDDER_REPO_URL} $(lsb_release -cs) main contrib non-free" > /etc/apt/sources.list.d/rudder.list

aptitude update

#Packages minimum
aptitude ${APTITUDE_ARGS} install debian-archive-keyring

aptitude ${APTITUDE_ARGS} install rudder-server-root

# Allow all connections to LDAP and PostgreSQL
sed -i "s/^IP=.*$/IP=*/" /etc/default/slapd
echo "listen_addresses = '*'" >> /etc/postgresql/8.4/main/postgresql.conf
echo "host    all         all         192.168.90.0/24       trust" >> /etc/postgresql/8.4/main/pg_hba.conf
echo "host    all         all         10.94.94.0/24       trust" >> /etc/postgresql/8.4/main/pg_hba.conf

/etc/init.d/postgresql restart

# Initialize Rudder
/opt/rudder/bin/rudder-init.sh $SERVER_INSTANCE_HOST $DEMOSAMPLE $LDAPRESET $INITPRORESET ${ALLOWEDNETWORK[0]} < /dev/null > /dev/null 2>&1

sed -i s%^base\.url\=.*%base\.url\=http\:\/\/server\.rudder\.local\:8080\/rudder% /opt/rudder/etc/rudder-web.properties

/etc/init.d/jetty restart

sed -i "s%^127\.0\.1\.1.*%127\.0\.1\.1\tserver\.rudder\.local\tserver%" /etc/hosts

echo "server" > /etc/hostname

hostname server

echo -e "\n192.168.42.11	node.rudder.local" >> /etc/hosts

echo '0,5,10,15,20,25,30,35,40,45,50,55 * * * * root if [ `ps -efww | grep cf-execd | grep "/var/rudder/cfengine-community/bin/cf-execd" | grep -v grep | wc -l` -eq 0 ]; then /var/rudder/cfengine-community/bin/cf-execd; fi' >> /etc/crontab

echo "Rudder server install: FINISHED" |tee /tmp/rudder.log
