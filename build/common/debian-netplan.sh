#/bin/bash

grep -qw bullseye /etc/os-release && {
	systemctl unmask systemd-networkd.service
	systemctl enable systemd-networkd.service
	sed -i 's/#CONFIGURE_INTERFACES=yes/CONFIGURE_INTERFACES=no/' /etc/default/networking
	rm -f /etc/network/interfaces
	exit 0
}

export DEBIAN_FRONTEND=noninteractive

apt install -y systemd-resolved netplan.io openvswitch-switch

systemctl enable systemd-networkd
systemctl enable systemd-resolved
systemctl enable ovsdb-server

apt -y remove ifupdown
rm -f /etc/network/interfaces

exit 0
