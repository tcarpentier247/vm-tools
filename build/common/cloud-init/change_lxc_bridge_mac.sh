#!/bin/bash

echo
echo "#################################"
echo "######## LXC BRIDGE MAC  ########"
echo "#################################"
echo

[[ -f ~opensvc/opensvc-qa.sh ]] && . ~opensvc/opensvc-qa.sh

# python uuid.getnode() does not like lxcbr0 hardcoded macaddress
[[ -f /etc/default/lxc-net ]] && {
    RMAC=$(echo `printf '00:16:3E:%02X:%02X:%02X\n' $[RANDOM%256] $[RANDOM%256] $[RANDOM%256]`)
    echo -e "\n# random lxcbr0 mac addr\nLXC_BRIDGE_MAC=\"$RMAC\"" >> /etc/default/lxc-net
}

exit 0
