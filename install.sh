#!/usr/bin/env bash

# drbd repos
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

# install pacemaker, httpd, drbd
yum -y install \
    pacemaker \
    pcs \
    resource-agents \
    httpd \
    php \
    drbd90-utils \
    kmod-drbd90

# pcs pass
echo kapparki | passwd --stdin hacluster

# copy generated hosts
cp /vagrant/hosts /etc/hosts

# httpd config
cp /vagrant/httpd.conf /etc/httpd/conf/httpd.conf

#corosync config
cp /vagrant/corosync.conf /etc/corosync/corosync.conf

# drbd config drbd
cp /vagrant/d0.res /etc/drbd.d/d0.res
