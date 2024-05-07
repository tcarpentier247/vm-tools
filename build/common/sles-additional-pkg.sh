!#/bin/bash

echo "start of virtualization packages installation"

zypper install -y qemu-kvm virt-install virt-manager guestfs-tools bridge-utils mkisofs

echo "packages successfully installed"

exit 0
