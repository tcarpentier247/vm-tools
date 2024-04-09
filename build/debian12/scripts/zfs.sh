#!/bin/bash -eu

echo "--- Begin zfs.sh ---"

export DEBIAN_FRONTEND=noninteractive

apt -y update && apt -y install zfsutils-linux

apt-mark hold zfsutils-linux zfs-zed zfs-dkms

echo "--- End zfs.sh ---"
