#!/bin/bash

echo
echo "######################"
echo "######## DRBD ########"
echo "######################"
echo

set -a

function install_drbd() {
    [[ -f /etc/debian_version ]] && {
        DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:linbit/linbit-drbd9-stack
        DEBIAN_FRONTEND=noninteractive apt-get update
        DEBIAN_FRONTEND=noninteractive apt --no-install-recommends -y install linux-headers-$(uname -r) drbd-dkms drbd-utils
    }
}

modprobe drbd 2>/dev/null || install_drbd

modprobe drbd || exit 1
modinfo drbd | grep ^version
typeset -i DRBD_MAJOR_VER=$(modinfo drbd | grep ^version | awk '{print $2}' | awk -F'.' '{print $1}')
[ ${DRBD_MAJOR_VER} -lt 9 ] && {
    echo "DRBD version error. Expecting 9+, found ${DRBD_MAJOR_VER}"
    modprobe -r drbd && install_drbd
}

DRBDTOP_BIN=/opt/archives/bin/drbdtop

[[ ! -f /usr/local/bin/drbdtop ]] && {
    sudo cp $DRBDTOP_BIN /usr/bin/drbdtop
    sudo chmod a+x /usr/bin/drbdtop
}

exit 0
