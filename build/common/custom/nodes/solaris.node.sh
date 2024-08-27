#!/bin/bash

PATH_SCRIPT="$(cd $(/usr/bin/dirname $(whence -- $0 2>/dev/null|| echo $0));pwd)"

[[ -x $PATH_SCRIPT/nodes.lib.sh ]] && . $PATH_SCRIPT/nodes.lib.sh

# check mac address
MAC=$(dladm show-linkprop -P -p mac-address net0 | grep ^net0 | gawk '{print $5}')

# decode mac
# 22:23:24:2a:0:11
# 22:23:23 is osvc vdc prefix
# 2a is hexadecimal cluster id
# 11 is prd ip addr
read -r A B C HEXCID E IPPRD <<<$(echo $MAC | gsed -e 's/:/ /g')

if [[ "$MAC" =~ ^"22:23:24:" ]]; then
    echo "$MAC belongs to osvc vdc"
else
    echo "MAC does not belong to osvc vdc"
    exit 0
fi

DECCID=$((16#$HEXCID))
read -r NODE x y IPPREFIX <<<$(egrep " $DECCID $IPPRD " ../../../../configs/vdc.nodes)
echo NODE=$NODE IPPREFIX=$IPPREFIX DECCID=$DECCID IPPRD=$IPPRD

# set system hostname
hostname $NODE

# build /etc/hosts
gen_etc_hosts $NODE $IPPREFIX.$DECCID.0.$IPPRD $IPPREFIX.$DECCID.1.$IPPRD $IPPREFIX.$DECCID.2.$IPPRD

# setup network
dladm show-phys net0 >>/dev/null 2>&1 && {
        createnic net0 $IPPREFIX $DECCID 0 $IPPRD 
        create_bridge br net0
}
dladm show-phys net1 >>/dev/null 2>&1 && createnic net1 $IPPREFIX $DECCID 1 $IPPRD
dladm show-phys net2 >>/dev/null 2>&1 && createnic net2 $IPPREFIX $DECCID 2 $IPPRD

# setup default route
netstat -nr | egrep "^default.*$IPPREFIX.$DECCID.0.1.*UG" >> /dev/null 2>&1 || {
    route -p add default $IPPREFIX.$DECCID.0.1
}

# setup resolver
NEED_REFRESH=""
setup_dns_client "$IPPREFIX.$DECCID.0.1 $IPPREFIX.$DECCID.1.1" '"vdc.opensvc.com"' 

# restore host ssh keys
[[ -f /export/home/packer/machines/$NODE/$NODE.ssh_host.tar.gz ]] && {
    cd /etc/ssh && tar xzf /export/home/packer/machines/$NODE/$NODE.ssh_host.tar.gz
}
setup_ssh
setup_root_role

echo "Restarting sshd service"
sudo svcadm restart svc:/network/ssh:default

setup_sudo_secure_path
setup_opensvc_user_path
setup_timezone

# setup iscsi
setup_iscsi $NODE $DECCID
