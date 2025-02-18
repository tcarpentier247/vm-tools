#!/bin/bash

which snapper >> /dev/null 2>&1 || exit 0

echo "Disabling Snapper"

snapper -c root set-config "TIMELINE_CREATE=no"
sed -i 's@USE_SNAPPER="yes"@USE_SNAPPER="no"@' /etc/sysconfig/yast2

echo "snap list before cleanup"
snapper --config root list

LAST_SNAP_ID=$(snapper --config root list | tail -1 | awk '{print $1}')
snapper --config root delete 2-$LAST_SNAP_ID

echo "snap list after cleanup"
snapper --config root list

zypper --non-interactive remove snapper snapper-zypp-plugin grub2-snapper-plugin yast2-snapper-plugin

exit 0
