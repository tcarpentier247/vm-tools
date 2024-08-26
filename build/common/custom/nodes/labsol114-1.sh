#!/bin/bash

[[ -x nodes.lib.sh ]] && . nodes.lib.sh

gen_etc_hosts labsol114-1 11.42.0.11 11.42.1.11 11.42.2.11

dladm show-phys net0 >>/dev/null 2>&1 && {
	createnic net0 11 42 0 11
        create_bridge br net0
}
dladm show-phys net1 >>/dev/null 2>&1 && createnic net1 11 42 1 11
dladm show-phys net2 >>/dev/null 2>&1 && createnic net2 11 42 2 11

netstat -nr | egrep "^default.*11.42.0.1.*UG" >> /dev/null 2>&1 || {
    route -p add default 11.42.0.1
}

NEED_REFRESH=""
setup_dns_client "11.42.0.1 11.42.1.1" '"vdc.opensvc.com"' 

setup_ssh
setup_root_role

echo "Restarting sshd service"
sudo svcadm restart svc:/network/ssh:default

setup_sudo_secure_path
setup_opensvc_user_path
setup_timezone
