#!/bin/bash

# generate $HOME/.ssh/config

set -a

PATH_SCRIPT="$(cd $(/usr/bin/dirname $(whence -- $0 2>/dev/null|| echo $0));pwd)"
cd $PATH_SCRIPT

. ../configs/environment || exit 1

PATTERN="^#|grafana|prometheus|keyclo|haproxy|squid|igw|svc|envoy|collector|registry|relay|vip|cname"

RELAYH=${1:localhost}
RELAYU=${1:username}

cat $NODES | grep -Ev "${PATTERN}" | while read host cluster index ipfirst
do
	#echo --- $host --- clusterid $cluster --- ip $index ---
	echo "Host $host"
	echo "   HostName ${RELAYH}"
	printf "   Port %d%02d%d\n" ${PORT_FWD[$ipfirst]} ${cluster} ${index}
	echo "   User ${RELAYU}"
	#echo "   StrictHostKeyChecking no"
	#echo "   UserKnownHostsFile=/dev/null"
done
