#!/bin/bash

echo "DRBD Build"

PATH=$PATH:/usr/local/bin:/usr/local/sbin
export PATH

apt -y install dpkg-dev build-essential linux-source libncurses5-dev autoconf curl linux-headers-`uname -r` linux-image-`uname -r`-dbg

KVER=`uname -r`
cp /usr/lib/debug/boot/System.map-$KVER /lib/modules/$KVER/build/System.map

# kernel module
DRBD=drbd-9.2.12
DRBDTAR=${DRBD}.tar.gz
wget https://pkg.linbit.com//downloads/drbd/9/${DRBDTAR}
tar xzf ${DRBDTAR}
cd ${DRBD}

make -j$(nproc)
make install
modinfo drbd | grep ^version
cd 

# tools
apt -y install flex libkeyutils-dev

DRBDUTILS=drbd-utils-9.29.0
DRBDUTILSTAR=${DRBDUTILS}.tar.gz
wget https://pkg.linbit.com//downloads/drbd/utils/${DRBDUTILSTAR}
tar xzf ${DRBDUTILSTAR}
cd ${DRBDUTILS}

./autogen.sh
./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc
make tools install-tools

cd
rm -rf drbd* coccinelle

exit 0
