#!/usr/bin/env bash

# run pacemaker services
systemctl enable pcsd
systemctl enable corosync
systemctl enable pacemaker

systemctl start pcsd
systemctl start corosync
systemctl start pacemaker
