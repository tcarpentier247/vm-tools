#!/bin/bash -eu

echo "--- Begin update.sh ---"

. /etc/profile

date; echo

pkg update --accept --no-backup-be

date; echo

echo "--- End update.sh ---"
