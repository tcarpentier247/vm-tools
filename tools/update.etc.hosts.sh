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
    #ipstring="$ipstring,$netA.$idx.$cpt.1/24"
    subnets["10.${idx}.0"]=""
    if (( $idx == 0 )); then
            let idx=$idx+1
	    continue
    fi
    subnets["10.${idx}.1"]="-hb1"
    subnets["10.${idx}.2"]="-hb2"
    let idx=$idx+1
done

[[ ! -f ${NODES} ]] && {
	echo "error: vdc.nodes is missing. exiting"
	exit 1
}

function gen_data()
{
    # prepare new entries
    printf "## OPENSVC LAB BEGIN ##\n"
    cat ${NODES} | grep -v '^#' | while read nodename cluid ip
    do
	#echo --- $nodename --- $cluid --- $ip
        for key in ${!subnets[@]}
        do
            [[ $key == 10.${cluid}.* ]] && {
                printf "%s.%s\t%s%s\t%s%s.vdc.opensvc.com\n" "$key" "$ip" "$nodename" "${subnets[$key]}" "$nodename" "${subnets[$key]}"
                net=$(echo $key | awk -F'.' '{printf "%02d", $3}')
                printf "%s\t%s%s-6\t%s%s-6.vdc.opensvc.com\n" "fd01:2345:6789:${cluid}${net}::$ip" "$nodename" "${subnets[$key]}" "$nodename" "${subnets[$key]}"
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
