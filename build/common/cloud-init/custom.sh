#!/bin/bash

echo
echo "########################"
echo "######## CUSTOM ########"
echo "########################"
echo

[[ -f ~opensvc/opensvc-qa.sh ]] && . ~opensvc/opensvc-qa.sh

test -x /nfs/data/archives/bin/hl && {
    echo "Copy hl binary to /usr/local/bin"
    cp /nfs/data/archives/bin/hl /usr/local/bin/hl
}

# drbd tunables
cat >| /etc/sysctl.d/98-opensvc-net.conf <<EOF
net.core.rmem_max=2097152
net.core.rmem_default=2097152
net.core.wmem_max=2097152
net.core.wmem_default=2097152
EOF

exit 0
