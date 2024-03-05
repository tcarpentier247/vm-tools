#!/bin/bash -eux

echo "--- Begin reboot.sh ---"

which systemctl > /dev/null 2>&1 && systemctl reboot
which pkginfo > /dev/null 2>&1 && init 6

echo "--- End reboot.sh ---"

exit 0
