#!/bin/bash

echo "--- Begin solaris cleanup.sh ---"

if [ -n "${ROOT_PASS}" ] ; then
    echo "reset root password to ${ROOT_PASS}"
    passwd -p "$(echo "${ROOT_PASS}" | pwhash -u root)" root
else
    echo "remove root password: passwd -N root"
    passwd -N root
fi
echo "switch root role: rolemod -K type=normal root"
rolemod -K type=normal root

rm -rf /opt/archives

echo "truncate any logs that have built up during the install"
find /var/log -type f -exec truncate --size=0 {} \;

echo "remove the contents of /var/tmp"
rm -rf /var/tmp/*

echo "clear the history so our install isn't there"
rm -f /root/.wget-hsts
export HISTSIZE=0

echo "Prepare once: /etc/rc0.d/K01cleanup" 
cat > /etc/rc0.d/K01cleanup <<EOF
#!/bin/bash

userdel packer

rm -f /etc/sudoers.d/svc-system-config-user /etc/sudoers.d/01-packer
sed -i -e '/^packer ALL=\(ALL\) NOPASSWD: ALL$/d' /etc/sudoers.d

zfs destroy rpool/export/home/packer
rm /etc/rc0.d/K01cleanup
sync; sync; sync
exit 0
EOF

chmod +x /etc/rc0.d/K01cleanup

echo "sync; sync"
sync; sync

echo "--- End solaris cleanup.sh ---"

exit 0
