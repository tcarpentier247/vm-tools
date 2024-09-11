#!/bin/bash -eu

echo "--- Begin update.sh ---"

. /etc/profile

date; echo

echo pkg set-publisher -G https://pkg.oracle.com/solaris/support/ -g http://pkg.oracle.com/solaris/release/ solaris
pkg set-publisher -G https://pkg.oracle.com/solaris/support/ -g http://pkg.oracle.com/solaris/release/ solaris || {
      echo "retry in 30s"
      sleep 30
      pkg set-publisher -G https://pkg.oracle.com/solaris/support/ -g http://pkg.oracle.com/solaris/release/ solaris || exit 1
  }

echo "pkg refresh"
pkg refresh

echo "pkg info entire"
pkg info entire

echo "pkg update --accept --no-backup-be"
pkg update --accept --no-backup-be
#pkg update --accept --no-backup-be pkg://solaris/entire@11.4-11.4.42.0.0.111.0

date; echo

echo "--- End update.sh ---"
