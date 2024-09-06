#!/bin/bash -eu

echo "--- Begin custom.sh ---"

. /etc/profile

echo "Set grub timeout to 2 seconds"
bootadm set-menu timeout=2

echo "Set grub to text mode"
bootadm set-menu console=text

echo "Removing cloudbase-init"
pkg uninstall cloudbase-init

echo "--- End custom.sh ---"
