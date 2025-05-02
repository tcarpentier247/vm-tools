#!/bin/bash
#

# filter is the cluster id integer to filter on
FILTER=$1
ECHO=echo
CLUSTERS=""
VDCNODES="/opt/vm-tools/configs/vdc.nodes"
DISKS_ROOT=/var/iscsi

ARRAY="targetcli"

function hinit() {
	[[ -f /tmp/hashmap.$1 ]] && rm -f /tmp/hashmap.$1*
}

function hput() {
	hash=$1
	shift
	key="$1"
	shift
	val="$@"
	previous=""
	[[ -f /tmp/hashmap.$hash ]] && {
		previous=$(grep "^$key " /tmp/hashmap.$hash | awk '{for (i=2; i<=NF; i++) printf $i " " };')
		cp /tmp/hashmap.$hash /tmp/hashmap.$hash.bck
		cat /tmp/hashmap.$hash.bck | grep -v "^$key " >/tmp/hashmap.$hash
	}
	echo "$key $previous $val" >>/tmp/hashmap.$hash
}

function hget() {
	key=$2
	grep "^$key " /tmp/hashmap.$1 | awk '{ for (i=2; i<=NF; i++) printf $i " "};'
	echo
}

function tiq {
	echo iqn.2009-11.com.opensvc.srv:$1.storage.target.$2
}

function istarget {
	local tgt=$1
	[[ -d /sys/kernel/config/target/iscsi/${tgt} ]] && return 0
	return 1
}

[[ ! -f $VDCNODES ]] && {
	echo "$VDCNODES not found. exiting"
	exit 1
}

[[ ! -d $DISKS_ROOT ]] && exit 1

hinit clusters

cp ${VDCNODES} ${VDCNODES}.nas

if [ -n "$FILTER" ]; then
	cat ${VDCNODES} | awk -v cid=${FILTER} '$2 == cid {print}' >|${VDCNODES}.nas
fi

cat $VDCNODES.nas | grep -Ev "^#|igw|vip|zone|envoy|svc|lxc|kvm|dck|collector|cname" | while read node clusterid ip; do
	hput clusters $clusterid $node
done

CLUSTERS=$(cat /tmp/hashmap.clusters | grep -v ^0 | awk '{printf "%s ", $1}')

for c in $CLUSTERS; do
	# delete lun presentation
	for n in $(hget clusters $c); do
		for t in $(seq 1 $TARGETS_PER_NODE); do
			target=$(tiq $n $t)
			istarget "$target" && $ECHO $ARRAY /iscsi delete $target
		done
	done

	# delete backstores/fileio
	for bckst in $($ARRAY ls /backstores/fileio | grep c${c} | awk '{print $2}')
	do
                $ECHO $ARRAY /backstores/fileio delete $bckst
	done

        # delete disk images
	cd $DISKS_ROOT && {
		for disk in $(ls -1 c${c}_* 2>/dev/null)
		do
			$ECHO rm -f $DISKS_ROOT/$disk
		done
	}
done
