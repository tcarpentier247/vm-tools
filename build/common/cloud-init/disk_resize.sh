#!/bin/bash

echo
echo "#############################"
echo "######## DISK RESIZE ########"
echo "#############################"
echo

[[ -f ~opensvc/opensvc-qa.sh ]] && . ~opensvc/opensvc-qa.sh

[[ ! -e /dev/vda ]] && {
	echo "error: /dev/vda not found"
        exit 1
}

# fix error below
# GPT PMBR size mismatch (20971519 != 62914559) will be corrected by write.
# The backup GPT table is not on the end of the device.
sgdisk -e /dev/vda

# resize last partition
(echo d; echo $(fdisk -l /dev/vda | grep -A1 '^/dev/vda' | tail -n 1 | awk '{print $1}' | sed 's/[^0-9]//g'); echo n; echo p; echo $(fdisk -l /dev/vda | grep -A1 '^/dev/vda' | tail -n 1 | awk '{print $1}' | sed 's/[^0-9]//g'); echo ; echo ; echo w) | fdisk /dev/vda && resize2fs /dev/vda$(fdisk -l /dev/vda | grep -A1 '^/dev/vda' | tail -n 1 | awk '{print $1}' | sed 's/[^0-9]//g')

# resize lvm pv
pvs -o name --noheadings | xargs -n1 pvresize

# resize root lv+fs
rootvg=$(vgs -o name --noheadings | grep -w root)
rootlv=$(lvs -o name,vg_name --noheadings | grep -w $rootvg | awk '{print $1}')
lvresize --resizefs --extents +100%FREE /dev/$rootvg/$rootlv

exit 0
