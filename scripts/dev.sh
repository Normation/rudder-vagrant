#!/bin/sh

sed -i "s/^IP=.*$/IP=*/" /opt/rudder/etc/rudder-slapd.conf 
echo "listen_addresses = '*'" >> /etc/postgresql/9.4/main/postgresql.conf
echo "host    all         all         192.168.42.0/24       trust" >> /etc/postgresql/9.4/main/pg_hba.conf
echo "host    all         all         10.0.0.0/16       trust" >> /etc/postgresql/9.4/main/pg_hba.conf
/etc/init.d/postgresql restart


if [ -e /opt/rudder/etc/rudder-passwords.conf ] ; then
  sed -i "s/\(RUDDER_WEBDAV_PASSWORD:\).*/\1rudder/" /opt/rudder/etc/rudder-passwords.conf
  sed -i "s/\(RUDDER_PSQL_PASSWORD:\).*/\1Normation/" /opt/rudder/etc/rudder-passwords.conf
  sed -i "s/\(RUDDER_OPENLDAP_BIND_PASSWORD:\).*/\1secret/" /opt/rudder/etc/rudder-passwords.conf
fi

rudder agent run

cp -a /vagrant/dev/fake-rudder.war /opt/rudder/jetty7/webapps/rudder.war

service rudder-jetty restart
