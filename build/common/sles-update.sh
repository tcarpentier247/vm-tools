#!/bin/bash

echo "Updating SUSE distribution"

zypper --non-interactive --gpg-auto-import-keys update

exit 0
