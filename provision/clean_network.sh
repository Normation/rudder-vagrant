#!/bin/sh

# Various cleanups to apply on the Vagrant boxes we use.
# no set -e since some things are expected to fail

# force DNS server to an always valid one (all)
cat << EOF > /etc/resolv.conf
# /etc/resolv.conf, built by rudder-vagrant
options rotate
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

chattr +i /etc/resolv.conf

# Install a clean /etc/hosts for Rudder to operate properly (all)
cat << EOF > /etc/hosts
# /etc/hosts, built by rudder-vagrant
#
# Format:
# IP-Address  Full-Qualified-Hostname  Short-Hostname
#

# IPv4
127.0.0.1       localhost
192.168.42.10	server.rudder.local server
192.168.42.11   node1.rudder.local node1
192.168.42.12   node2.rudder.local node2
192.168.42.13   node3.rudder.local node3
192.168.42.14   node4.rudder.local node4
192.168.42.15   node5.rudder.local node5
192.168.42.16   node6.rudder.local node6
192.168.42.17   node7.rudder.local node7
192.168.42.18   node8.rudder.local node8
192.168.42.19   node9.rudder.local node9
192.168.42.20   node10.rudder.local node10

# IPv6
::1             localhost ipv6-localhost ipv6-loopback

fe00::0         ipv6-localnet

ff00::0         ipv6-mcastprefix
ff02::1         ipv6-allnodes
ff02::2         ipv6-allrouters
ff02::3         ipv6-allhosts
EOF


