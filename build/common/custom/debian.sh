#/bin/bash

[[ -f /etc/default/grub ]] && {
    cp /etc/default/grub /etc/default/grub.osvcpacker
    sed -i 's#^GRUB_CMDLINE_LINUX_DEFAULT=.*$#GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0,115200n8"#' /etc/default/grub
    update-grub || exit 1
}

[[ -f /tmp/archives/var.cache.lxc.tar ]] && {
	echo "Loading LXC cache"
	[[ ! -d /var/cache/lxc ]] && mkdir -p /var/cache/lxc
	cd /var/cache/lxc && tar xpf /tmp/archives/var.cache.lxc.tar
}

exit 0
