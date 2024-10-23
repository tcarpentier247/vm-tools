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

exit 0
