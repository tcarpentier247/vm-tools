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
echo "--- Installing software ---"
echo
/opt/csw/bin/pkgutil -y -i \
	autoconf \
	autogen \
	bash \
	binutils \
	bzip2 \
	coreutils \
	curl \
	findutils \
	gawk \
	gcc5g++ \
	git \
	git_completion \
	gmake \
	gzip \
	jq \
	less \
	lsof \
	ncdu \
	netcat \
	openssl_utils \
	pstree \
	psutils \
	rsync \
	socat \
	tcpdump \
	tree \
	vim \
	watch \
	wget \
	which \
	wireshark	

#echo "--- sleeping ---"
#sleep 36000

#mkdir -p /export/home/packer/.cache/pip /export/home/packer/.ansible/galaxy_cache
#chown -R packer:staff /export/home/packer

echo "--- Installing cwPython 3.9, system/storage/sg3_utils ---"
yes|pkg install python-39 system/storage/sg3_utils

echo "--- Upgrading pip3 ---"
python3.9 -m pip install --upgrade pip

echo "--- Installing ansible ---"
pip3 install ansible
ansible --version || exit 1

echo "--- Updating PATH in /etc/profile ---"
echo >> /etc/profile
echo 'PATH=$PATH:/opt/csw/bin' >> /etc/profile
echo 'export PATH' >> /etc/profile

echo "--- End software.sh ---"
