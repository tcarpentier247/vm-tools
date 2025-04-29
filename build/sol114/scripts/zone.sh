#!/bin/bash -eu

echo "--- Begin zone.sh ---"

. /etc/profile

date

##############
# SOLARIS 10 #
##############
echo -e "---\ncreating sol10 zone\n---"

cat - <<EOF >/var/tmp/sysidcfg.unconfig
system_locale=C
timezone=MET
terminal=vt100
timeserver=localhost
security_policy=NONE
root_password=NP
auto_reg=disable
nfs4_domain=dynamic
network_interface=NONE {hostname=skelzone10-opensvc}
name_service=NONE
EOF

echo "------------------- /var/tmp/sysidcfg.unconfig ----------------------"
cat /var/tmp/sysidcfg.unconfig
echo "------------------- /var/tmp/sysidcfg.unconfig ----------------------"

/usr/sbin/zonecfg -z skelzone10-opensvc create -t SYSsolaris10
/usr/sbin/zonecfg -z skelzone10-opensvc remove -F anet
echo "will install"
date

/usr/sbin/zoneadm -z skelzone10-opensvc install -c /var/tmp/sysidcfg.unconfig -a /var/tmp/skelzone10-opensvc@provision -u

echo "install done"
date

rm -f /var/tmp/skelzone10-opensvc@provision

##############
# SOLARIS 11 #
##############
echo -e "---\ncreating sol11 zone\n---"

cat - <<EOF >/var/tmp/skelzone-manifest.xml
<!--

 Copyright (c) 2011, 2018, Oracle and/or its affiliates. All rights reserved.


-->
<!DOCTYPE auto_install SYSTEM "file:///usr/share/install/ai.dtd.1">
<auto_install>
    <ai_instance name="zone_default">
        <target>
            <logical>
                <zpool name="rpool">
                    <!--
                                Subsequent <filesystem> entries instruct an installer
                                to create the following ZFS datasets:

                                    <root_pool>/export         (mounted on /export)
                                    <root_pool>/export/home    (mounted on /export/home)

                                Those datasets are part of standard environment
                                and should always be created.

                                In rare cases, if there is a need to deploy a zone
                                without these datasets, either comment out or remove
                                <filesystem> entries. In such scenario, it has to be also
                                assured that in case of non-interactive post-install
                                configuration, creation of initial user account is
                                disabled in related system configuration profile.
                                Otherwise the installed zone would fail to boot.
                              -->
                    <filesystem name="export" mountpoint="/export"/>
                    <filesystem name="export/home"/>
                    <be name="solaris">
                        <options>
                            <option name="compression" value="on"/>
                        </options>
                    </be>
                </zpool>
            </logical>
        </target>
        <software type="IPS">
            <destination>
                <image>
                    <!-- Specify locales to install -->
                    <facet set="true">facet.locale.en_US</facet>
                </image>
            </destination>
            <software_data action="install">
                <name>pkg:/group/system/solaris-small-server</name>
                <name>pkg:/runtime/python-37</name>
                <name>pkg:/package/svr4</name>
                <name>pkg:///entire@11.4-11.4.42.0.0.111.0:20211203T221558Z</name>
            </software_data>
        </software>
    </ai_instance>
</auto_install>
EOF

/usr/sbin/zonecfg -z skelzone-opensvc-ai create
/usr/sbin/zonecfg -z skelzone-opensvc-ai remove -F anet
/usr/sbin/zoneadm -z skelzone-opensvc-ai install -c /usr/share/auto_install/sc_profiles/unconfig.xml -m /var/tmp/skelzone-manifest.xml
echo "skelzone-opensvc-ai: boot"
date
/usr/sbin/zoneadm -z skelzone-opensvc-ai boot

echo "waiting for skelzone-opensvc-ai /milestone/multi-user..."
while [ "$(zlogin skelzone-opensvc-ai svcs -H -o STA svc:/milestone/multi-user:default 2>/dev/null)" != "ON" ] ; do printf .; sleep 1 ; done
echo
echo "skelzone-opensvc-ai: will init 0"
date
/usr/sbin/zlogin skelzone-opensvc-ai /sbin/init 0
echo "skelzone-opensvc-ai: init 0 ended"
date

sleep 180
date

echo -e "---\nlisting sol zone\n---"

zoneadm list -cvi

for zone in skelzone10-opensvc skelzone-opensvc-ai
do
	zoneadm list -cvi | /usr/gnu/bin/grep -q "$zone installed" || exit 1
done	

echo "--- End zone.sh ---"
