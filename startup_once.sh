# setup drbd primary and copy code onto the device

drbdadm --force primary d0
mkfs.ext4 /dev/drbd0

mount /dev/drbd0 /mnt
cp /vagrant/editor.php /mnt/index.php
umount /mnt

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

systemctl start drbd

# create a drbd service
# pcs cluster cib drbd_cfg

# pcs -f drbd_cfg resource create \
#     DRBDData ocf:linbit:drbd drbd_resource=d0 \
#     op monitor interval=10s

# pcs -f drbd_cfg resource master \
#     DRBDDataClone DRBDData \
#     master-max=1 master-node-max=1 clone-max=2 clone-node-max=1 notify=true

# pcs -f drbd_cfg resource show

# pcs cluster cib-push drbd_cfg

# pcs status

pcs cluster cib fs_cfg

pcs -f fs_cfg resource create \
    DRBDFS Filesystem device="/dev/drbd0" directory="/var/www/html" fstype="ext4"

# pcs -f fs_cfg constraint colocation add DRBDFS with DRBDDataClone INFINITY with-rsc-role=Master
# pcs -f fs_cfg constraint order promote DRBDDataClone then start DRBDFS

pcs -f fs_cfg constraint colocation add FloatingIPAddress with DRBDFS INFINITY
pcs -f fs_cfg constraint order DRBDFS then FloatingIPAddress

pcs cluster cib-push fs_cfg

# default timeout
pcs resource op defaults timeout=10s