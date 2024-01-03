#!/bin/bash

PATH_SCRIPT="$(cd $(/usr/bin/dirname $(whence -- $0 2>/dev/null|| echo $0));pwd)"
cd $PATH_SCRIPT

. ../configs/environment || exit 1

TEMPLATE=${TEMPLATES}/network_template.xml
NETCFGDIR=${CONFIGS}/networks
MYVIRSH="echo virsh"

function gennetxml()
{
    local _cid=$1
    local _net=$2
    local _cpt=$3
    local _mac=$(printf "%02d" "$_cid")

    #echo "$0 cid $_cid   net $_net  cpt $_cpt   mac $_mac"

    cat ${TEMPLATE} | sed -e "s/CID/$_cid/g;s/ENV/$_net/g;s/NUM/$_cpt/g;s/MAC/$_mac/g"
}

function setupnet()
{
    local _cid=$1
    local _net=$2
    [[ ! -f /etc/libvirt/qemu/networks/c$_cid-$_net.xml ]] && {
        $MYVIRSH net-define $NETCFGDIR/c$_cid-$_net.xml
        $MYVIRSH net-start c$_cid-$_net
        $MYVIRSH net-autostart c$_cid-$_net
    }
}

[ ! -d $NETCFGDIR ] && mkdir -p ${NETCFGDIR}

for cid in $(seq 0 $CLUSTER_COUNT)
do
    typeset -i cpt=0
    for net in prd hb1 hb2
    do
	gennetxml $cid $net $cpt > $NETCFGDIR/c$cid-$net.xml
#	gennetxml $cid $net $cpt
	setupnet $cid $net
	let cpt=$cpt+1
    done
done

