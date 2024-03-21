#!/bin/bash

echo "DRBD Build"

PATH=$PATH:/usr/local/bin:/usr/local/sbin
export PATH

yum -y install gcc glibc-devel git kernel-devel make perl rpm-build tar wget keyutils-libs-devel

# coccinelle / spatch prereq
#dnf -y install pkgconfig chrpath ocaml ocaml-findlib ocaml-findlib-devel ocaml-ocamldoc
#zypper --non-interactive --gpg-auto-import-keys install chrpath ocaml ocaml-findlib ocaml-findlib-devel ocaml-ocamldoc 

#git clone https://github.com/coccinelle/coccinelle.git
#cd coccinelle
#./autogen
#./configure
#make -j$(nproc)
#make install
#which spatch || exit 1
#cd

# kernel module
DRBD=drbd-9.2.7
DRBDTAR=${DRBD}.tar.gz
wget --no-check-certificate https://pkg.linbit.com//downloads/drbd/9/${DRBDTAR}
tar xzf ${DRBDTAR}
cd ${DRBD}

make -j$(nproc)
make install
modinfo drbd | grep ^version
cd 

RUBY_DOC_PKG="ruby2.5-rubygem-asciidoctor"
grep -q '12-' /etc/os-release && RUBY_DOC_PKG="ruby2.1-rubygem-asciidoctor"

# drbd tools
##zypper --non-interactive --gpg-auto-import-keys install $RUBY_DOC_PKG po4a flex keyutils-devel
##dnf -y install $RUBY_DOC_PKG flex keyutils-devel

DRBDUTILS=drbd-utils-9.27.0
DRBDUTILSTAR=${DRBDUTILS}.tar.gz
wget --no-check-certificate https://pkg.linbit.com//downloads/drbd/utils/${DRBDUTILSTAR}
tar xzf ${DRBDUTILSTAR}
cd ${DRBDUTILS}

./autogen.sh
./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc
make tools install-tools

cd
rm -rf drbd* coccinelle

exit 0
