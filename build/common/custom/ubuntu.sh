#/bin/bash

[[ -f /etc/default/grub ]] && {
    cp /etc/default/grub /etc/default/grub.osvcpacker
    sed -i 's#^GRUB_CMDLINE_LINUX_DEFAULT=.*$#GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0,115200n8"#' /etc/default/grub
    grep -q '^GRUB_TERMINAL=' /etc/default/grub || echo 'GRUB_TERMINAL="console serial"' >> /etc/default/grub
    sed -i 's/GRUB_TIMEOUT_STYLE=hidden/GRUB_TIMEOUT_STYLE=menu/' /etc/default/grub
    sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=3/' /etc/default/grub
    update-grub || exit 1
}

for file in /etc/cloud/cloud.cfg.d/99-installer.cfg /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg
do
    [[ -f $file ]] && {
        echo "removing $file"
        rm -f $file
    }
done

[[ -f /opt/archives/var.cache.lxc.tar ]] && {
	echo "Loading LXC cache"
	[[ ! -d /var/cache/lxc ]] && mkdir -p /var/cache/lxc
	cd /var/cache/lxc && tar xpf /opt/archives/var.cache.lxc.tar
}


exit 0
