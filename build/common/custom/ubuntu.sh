#/bin/bash

[[ -f /etc/default/grub ]] && {
    cp /etc/default/grub /etc/default/grub.osvcpacker
    sed -i 's#^GRUB_CMDLINE_LINUX_DEFAULT=.*$#GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0,115200n8"#' /etc/default/grub
    grep -q '^GRUB_TERMINAL=' /etc/default/grub || echo 'GRUB_TERMINAL="console serial"' >> /etc/default/grub
    sed -i 's/GRUB_TIMEOUT_STYLE=hidden/GRUB_TIMEOUT_STYLE=menu/' /etc/default/grub
    sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=3/' /etc/default/grub
    update-grub || exit 1
}

exit 0
