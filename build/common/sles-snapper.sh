#!/bin/bash

echo "Disabling Snapper"

snapper -c root set-config "TIMELINE_CREATE=no"
sed -i 's@USE_SNAPPER="yes"@USE_SNAPPER="no"@' /etc/sysconfig/yast2
