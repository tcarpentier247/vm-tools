#!/bin/bash

echo
echo "#####################"
echo "######## LVM ########"
echo "#####################"
echo

[[ -f ~opensvc/opensvc-qa.sh ]] && . ~opensvc/opensvc-qa.sh

ROOTVG=$(lvs --noheadings -o name,vg_name 2>/dev/null | grep -Ev "c[0-9]{1,2}svc.*|cluster|scsi3"  | grep -Ew 'root|ubuntu-vg' | awk '{print $2}' | sort -u)

grep -q 'use_lvmetad = 1' /etc/lvm/lvm.conf || {
echo "Disable lvmetad"
cp /etc/lvm/lvm.conf /etc/lvm/lvm.conf.preosvc
cat /etc/lvm/lvm.conf.preosvc | sed -e 's/use_lvmetad = 1/use_lvmetad = 0/g' > /etc/lvm/lvm.conf
rm -f /etc/lvm/lvm.conf.preosvc
}

grep -q 'hosttags = 1' /etc/lvm/lvm.conf || {
echo "Enable lvm hosttags parameter"
cat - <<EOF >>/etc/lvm/lvm.conf
tags {
    hosttags = 1
    local {}
}
EOF
}

grep -q volume_list /etc/lvm/lvm_$HOSTNAME.conf >> /dev/null 2>&1 || {
echo "Configure lvm hosttags"
cat - <<EOF >>/etc/lvm/lvm_$HOSTNAME.conf
activation {
    volume_list = ["@local", "@$HOSTNAME"]
}
EOF
}

grep ' / ' /proc/mounts | grep -q btrfs && {
    echo "root filesystem is btrfs type. local tag not needed"
    exit 0
}

if [ ! -z ${ROOTVG} ]
then
	echo "Add tag local to rootvg"
	vgchange --addtag local ${ROOTVG}
else
    echo "ROOTVG is empty. Exiting."
    exit 1
fi

if [ -b /dev/vdb ]
then
    echo "Creating data vg on /dev/vdb"
    wipefs -af /dev/vdb
    pvcreate -f /dev/vdb
    vgcreate data /dev/vdb
    vgchange --addtag local data
fi

exit 0
