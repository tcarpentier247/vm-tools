#!/bin/bash

# hypervisor /etc/hosts is served through dnsmasq on each cluster subnet
# each cluster node is dns resolving on the bridge ip, where dnsmasq is listening

set -a

PATH_SCRIPT="$(cd $(/usr/bin/dirname $(whence -- $0 2>/dev/null|| echo $0));pwd)"
cd $PATH_SCRIPT

. ../configs/environment || exit 1

echo "Updating /etc/hosts with vdc nodes records"

TIMESTAMP=$(date -u +%Y%m%d%H%M%S)

# build subnets table
declare -A subnets
typeset -i idx=0

while [[ $idx -lt $CLUSTER_COUNT ]]
do
    for net in $(cat ${NODES} | grep -v '^#' | awk '{print $4}' | sort -u)
    do
        subnets["${net}.${idx}.0"]=""
        subnets["${net}.${idx}.1"]="-hb1"
        subnets["${net}.${idx}.2"]="-hb2"
    done
    let idx=$idx+1
done

# no hb on infra subnets
unset subnets["10.0.1"]
unset subnets["10.0.2"]
unset subnets["11.0.1"]
unset subnets["11.0.2"]

[[ ! -f ${NODES} ]] && {
	echo "error: vdc.nodes is missing. exiting"
	exit 1
}

function gen_data()
{
    # prepare new entries
    printf "## OPENSVC LAB BEGIN ##\n"
    cat ${NODES} | grep -v '^#' | while read nodename cluid iplast ipfirst
    do
	#echo --- $nodename --- $cluid --- $iplast
        for key in ${!subnets[@]}
        do
            [[ $key == ${ipfirst}.${cluid}.* ]] && {
                printf "%s.%s\t%s%s\t%s%s.vdc.opensvc.com\n" "$key" "$iplast" "$nodename" "${subnets[$key]}" "$nodename" "${subnets[$key]}"
                net=$(echo $key | awk -F'.' '{printf "%02d", $3}')
                printf "%s\t%s%s-6\t%s%s-6.vdc.opensvc.com\n" "fd01:2345:6789:${cluid}${net}::$iplast" "$nodename" "${subnets[$key]}" "$nodename" "${subnets[$key]}"
            }
        done
    done
    printf "## OPENSVC LAB END ##\n"
}

function clean_hosts()
{
    # remove old entries
    cp -pf /etc/hosts /etc/hosts.$TIMESTAMP && {
        cat /etc/hosts.$TIMESTAMP | sed '/## OPENSVC LAB BEGIN ##/,/## OPENSVC LAB END ##/d' > /etc/hosts
    }
    find /etc -name \*hosts.2\* -ctime +7 -exec rm -f {} \;
}

clean_hosts

gen_data > $NODES.etc.hosts

cat $NODES.etc.hosts >> /etc/hosts

# updating nfs share
for file in $NODES $NODES.etc.hosts
do
    cp $file /data/nfsshare/
done

ps aux|grep [d]nsmasq|awk '{print $2}'|xargs sudo kill -HUP
