#!/bin/bash -eu

echo "--- Begin software.sh ---"

. /etc/profile

NOASK_FILE=/tmp/noask
INPUT_FILE=/tmp/input

echo "mail=
instance=overwrite
partial=nocheck
runlevel=nocheck
idepend=nocheck
rdepend=nocheck
space=nocheck
setuid=nocheck
conflict=nocheck
action=nocheck
basedir=default" > $NOASK_FILE

echo "all" > $INPUT_FILE

pkgadd -a $NOASK_FILE -d http://get.opencsw.org/now < $INPUT_FILE

cp -f /opt/csw/etc/pkgutil.conf /opt/csw/etc/pkgutil.conf.install && \
    /usr/xpg4/bin/awk '1;/^#mirror=http/ {print "mirror=http://mirrors.ircam.fr/pub/OpenCSW/testing"}' /opt/csw/etc/pkgutil.conf.install > /opt/csw/etc/pkgutil.conf
 
echo "--- Updating csw package cache ---"
/opt/csw/bin/pkgutil -U
echo

echo "--- Installing runtime/python-39 library/python/pip-39 library/python/pip system/storage/sg3_utils ... ---"
echo pkg install runtime/python-39 \
    library/python/pip-39 \
    developer/versioning/git \
    developer/python/pylint-39 \
    developer/build/autoconf \
    developer/build/autogen \
    group/feature/developer-gnu \
    file/gnu-coreutils \
    file/gnu-findutils \
    file/tree \
    diagnostic/wireshark \
    diagnostic/tcpdump \
    diagnostic/top \
    network/netcat \
    network/rsync \
    shell/watch \
    text/jq \
    web/wget \
    editor/vim \
    system/storage/sg3_utils \
    group/feature/developer-gnu

pkg install runtime/python-39 \
    library/python/pip-39 \
    developer/versioning/git \
    developer/python/pylint-39 \
    developer/build/autoconf \
    developer/build/autogen \
    file/gnu-coreutils \
    file/gnu-findutils \
    file/tree \
    diagnostic/wireshark \
    diagnostic/tcpdump \
    diagnostic/top \
    network/netcat \
    network/rsync \
    shell/watch \
    text/jq \
    web/wget \
    editor/vim \
    system/storage/sg3_utils \
    group/feature/developer-gnu

echo "pkg set-mediator -V 3.9 python"
pkg set-mediator -V 3.9 python

echo "prepare packer & ansible dirs"
mkdir -p /export/home/packer/.cache/pip /export/home/packer/.ansible/galaxy_cache
chown -R packer:staff /export/home/packer

echo "--- Installing ansible ---"
/usr/bin/pip install ansible
ansible --version || { sleep 240; exit 1; }

echo "--- Updating PATH in /etc/profile ---"
echo >> /etc/profile
echo 'PATH=/usr/gnu/bin:$PATH:/opt/csw/bin' >> /etc/profile
echo 'export PATH' >> /etc/profile

echo "--- End software.sh ---"
