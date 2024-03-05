#!/bin/bash -eu

echo "--- Begin zfs.sh ---"

export DEBIAN_FRONTEND=noninteractive

dnf update -y && dnf install -y zfsutils-linux

echo "--- End zfs.sh ---"
