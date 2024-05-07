#!/bin/bash

export DEBIAN_FRONTED=noninteractive

apt install -y qemu-kvm virtinst virt-manager libguestfs-tools bridge-utils genisoimage

exit 0
