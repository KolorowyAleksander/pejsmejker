
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

pcs resource create \
    Apache ocf:heartbeat:apache \
    configfile=/etc/httpd/conf/httpd.conf \
    statusurl="http://127.0.0.1/server-status" \
    op monitor interval=20s

pcs constraint colocation add Apache FloatingIPAddress INFINITY
pcs constraint order FloatingIPAddress then Apache