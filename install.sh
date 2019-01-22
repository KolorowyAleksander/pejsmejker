#!/usr/bin/env bash

# install pacemaker
yum -y install \
    pacemaker \
    pcs \
    resource-agents \
    httpd \
    drbd-utils

# pcs pass
echo CHANGEME | passwd --stdin hacluster

# hosts
(cat >> /etc/hosts) <<EOF
192.168.10.11   n1
192.168.10.12   n2
192.168.10.13   n3
EOF

#corosync config
cp /vagrant/corosync.conf /etc/corosync/corosync.conf

# the fucking php file editor
cp /vagrant/tinyfilemanager.php /var/www/html/manager.php

# firewall-cmd --permanent --add-service=high-availability
# firewall-cmd --add-service=high-availability