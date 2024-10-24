#!/bin/bash

echo
echo "#####################"
echo "######## LXC ########"
echo "#####################"
echo

[[ -f ~opensvc/opensvc-qa.sh ]] && . ~opensvc/opensvc-qa.sh

systemctl enable lxc-net

grep -q 'USE_LXC_BRIDGE="true"' /etc/default/lxc-net 2>/dev/null || {
	echo 'USE_LXC_BRIDGE="true"' >> /etc/default/lxc-net
}

[[ ! -f /usr/share/lxc/config/ubuntu.common.conf ]] && {
    cp -f /usr/share/lxc/config/common.conf /usr/share/lxc/config/ubuntu.common.conf
}

exit 0
