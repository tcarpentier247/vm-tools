#/bin/bash

[[ -f /etc/default/grub ]] && {
    cp /etc/default/grub /etc/default/grub.osvcpacker
    sed -i 's#^GRUB_CMDLINE_LINUX_DEFAULT=.*$#GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0,115200n8"#' /etc/default/grub
}

exit 0
