#!/usr/bin/env bash

vagrant ssh n1 -c "sudo systemctl start drbd"
vagrant ssh n2 -c "sudo systemctl start drbd"
vagrant ssh n3 -c "sudo systemctl start drbd"
vagrant ssh n2 -c "sudo bash /vagrant/startup_once.sh"