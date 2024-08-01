#!/bin/bash

which snapper >> /dev/null 2>&1 || exit 0

echo "Disabling Snapper"

snapper -c root set-config "TIMELINE_CREATE=no"
sed -i 's@USE_SNAPPER="yes"@USE_SNAPPER="no"@' /etc/sysconfig/yast2

zypper --non-interactive remove snapper snapper-zypp-plugin grub2-snapper-plugin yast2-snapper-plugin

exit 0
