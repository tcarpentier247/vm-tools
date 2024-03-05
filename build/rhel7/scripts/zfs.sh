#!/bin/bash

echo "--- Begin zfs.sh ---"

export DEBIAN_FRONTEND=noninteractive

yum update -y && yum install -y zfsutils-linux

echo "--- End zfs.sh ---"

exit 0
