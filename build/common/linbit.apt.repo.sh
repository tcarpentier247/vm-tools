#!/bin/bash
#
[[ ${LINBIT_KEY} == "undefined" ]] && {
    echo "Error: variable LINBIT_KEY is not defined"
    exit 1
}

[[ ! -f /etc/os-release ]] && {
    echo "/etc/os-release not found"
    exit 1
}

. /etc/os-release

[[ -f /etc/apt/sources.list.d/linbit.list ]] && rm -f /etc/apt/sources.list.d/linbit.list

wget -q -O /dev/shm/linbit-keyring.deb https://packages.linbit.com/public/linbit-keyring.deb || {
    echo "Error: could not download Linbit keyring package"
    exit 1
}

apt -y install /dev/shm/linbit-keyring.deb

cat > /etc/apt/sources.list.d/linbit.list <<EOF
deb [signed-by=/etc/apt/trusted.gpg.d/linbit-keyring.gpg] https://packages.linbit.com/${LINBIT_KEY}/ ${VERSION_CODENAME} drbd-9
EOF

apt update

apt -y install drbd-utils drbd-dkms

modprobe drbd || exit 1
modinfo drbd | grep ^version
typeset -i DRBD_MAJOR_VER=$(modinfo drbd | grep ^version | awk '{print $2}' | awk -F'.' '{print $1}')
[ ${DRBD_MAJOR_VER} -lt 9 ] && {
    echo "DRBD version error. Expecting 9+, found ${DRBD_MAJOR_VER}"
    exit 1
}

exit 0
