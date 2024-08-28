#!/bin/bash

set -a

PATH_SCRIPT="$(cd $(/usr/bin/dirname $(whence -- $0 2>/dev/null|| echo $0));pwd)"
cd $PATH_SCRIPT

. ../configs/environment || exit 1

# $1 vm path
#
# example
# ./kvm.unprovision.sh /data/vms/rhel8/qarh8c18n1

VM_ROOT=$1


echo "begin sleep 5 $VM_ROOT" | systemd-cat
sleep 5
echo "end sleep 5 $VM_ROOT" | systemd-cat
echo "begin rm $VM_ROOT" | systemd-cat
[[ ! -z $VM_ROOT ]] && rm -rf $VM_ROOT
echo "end rm $VM_ROOT" | systemd-cat

