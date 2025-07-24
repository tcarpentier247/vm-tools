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

exit 0
