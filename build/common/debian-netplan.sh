#/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt install -y systemd-resolved netplan.io openvswitch-switch

systemctl enable systemd-networkd
systemctl enable systemd-resolved
systemctl enable ovsdb-server

apt -y remove ifupdown
rm -f /etc/network/interfaces

exit 0
