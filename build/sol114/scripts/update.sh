#!/bin/bash -eu

echo "--- Begin update.sh ---"

. /etc/profile

date; echo

pkg update --accept --no-backup-be
#pkg update --accept --no-backup-be pkg://solaris/entire@11.4-11.4.42.0.0.111.0

date; echo

echo "--- End update.sh ---"
