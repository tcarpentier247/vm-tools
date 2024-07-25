#/bin/bash

[[ ! -d /var/lib/opensvc/cni/net.d ]] && mkdir -p /var/lib/opensvc/cni/net.d

cat >| /var/lib/opensvc/cni/net.d/podman.conf <<EOF
{
    "cniVersion": "0.3.0",
    "name": "podman",
    "type": "loopback"
}
EOF

timedatectl | grep -q 'RTC in local TZ: yes' && {
	timedatectl set-local-rtc 0
}
