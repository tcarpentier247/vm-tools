#!/bin/bash

echo
echo "#########################"
echo "######## NETWORK ########"
echo "#########################"
echo

[[ -f ~opensvc/opensvc-qa.sh ]] && . ~opensvc/opensvc-qa.sh

ls -l /nfs/data

[[ -f /nfs/data/vdc.nodes.etc.hosts ]] && {
    echo "Updating /etc/hosts"
    echo -e "\n# added by osvc build" >> /etc/hosts
    PATTERN=${HOSTNAME:0:6}
    grep $PATTERN /nfs/data/vdc.nodes.etc.hosts >> /etc/hosts

    echo "Updating /etc/vdc.nodes.hosts for system/svc/odns"
    cp /nfs/data/vdc.nodes.etc.hosts /etc/vdc.nodes.etc.hosts
}

exit 0
