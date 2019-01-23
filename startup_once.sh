# setup drbd primary and copy code onto the device

drbdadm --force primary d0
mkfs.ext4 /dev/drbd0

mount /dev/drbd0 /mnt
cp /vagrant/editor.php /mnt/index.php
chmod -R 777 /mnt
umount /mnt

drbdadm secondary d0

# setup cluster
pcs cluster auth n1 n2 n3 -u hacluster -p CHANGEME --force
pcs cluster setup --force --name pejsmejker n1 n2 n3
pcs cluster start --all

# set cluster properties
pcs property set stonith-enabled=false
pcs property set no-quorum-policy=ignore

# create a floatin IP
pcs resource create \
    FloatingIPAddress IPaddr2 ip=192.168.10.10 cidr_netmask=24 \
    op monitor interval=1s

# start apache
pcs resource create \
    Apache ocf:heartbeat:apache \
    configfile=/etc/httpd/conf/httpd.conf \
    statusurl="http://127.0.0.1/server-status" \
    op monitor interval=20s

pcs constraint colocation add Apache FloatingIPAddress INFINITY
pcs constraint order FloatingIPAddress then Apache

pcs cluster cib fs_cfg

pcs -f fs_cfg resource create \
    DRBDFS Filesystem device="/dev/drbd0" directory="/var/www/html" fstype="ext4"

pcs -f fs_cfg constraint colocation add FloatingIPAddress with DRBDFS INFINITY
pcs -f fs_cfg constraint order DRBDFS then FloatingIPAddress

pcs cluster cib-push fs_cfg

# default timeout
pcs resource op defaults timeout=10s