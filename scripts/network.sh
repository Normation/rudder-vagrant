#!/bin/sh


NET="$1"
HOSTS="$2"

# Install a clean /etc/hosts for Rudder to operate properly (all)
cat << EOF > /etc/hosts
# /etc/hosts, built by rtf (Rudder Test Framwork)
#
# Format:
# IP-Address  Full-Qualified-Hostname  Short-Hostname
#

# IPv4
127.0.0.1       localhost

EOF

i=2
for host in ${HOSTS}
do
  echo "${NET}.${i}    ${host}.rudder.local ${host}" >> /etc/hosts
  i=`expr $i + 1`
done

cat << EOF >> /etc/hosts

# IPv6
::1             localhost ipv6-localhost ipv6-loopback

fe00::0         ipv6-localnet

ff00::0         ipv6-mcastprefix
ff02::1         ipv6-allnodes
ff02::2         ipv6-allrouters
ff02::3         ipv6-allhosts
EOF
