resource d0 {
	net {
		protocol C;
	}
	device /dev/drbd0;
	disk /dev/sdb;
	meta-disk internal;
	on n1 {
		address 192.168.10.11:7788;
		node-id 0;
	}
	on n2 {
		address 192.168.10.12:7788;
		node-id 1;
	}
	on n3 {
		address 192.168.10.13:7788;
		node-id 2;
	}
	disk {
		resync-rate 110M;
	}
	connection-mesh {
		hosts n1 n2 n3;
	}
}