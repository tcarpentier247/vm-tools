#!/bin/bash

# enable serial console
[[ -f /etc/default/grub ]] && {
    cp /etc/default/grub /etc/default/grub.osvcpacker
    # https://access.redhat.com/articles/7212
    sed -i 's#^GRUB_CMDLINE_LINUX_DEFAULT=.*$#GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0,115200n8"#' /etc/default/grub
    grep -q '^GRUB_CMDLINE_LINUX_DEFAULT' /etc/default/grub || echo 'GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0,115200n8"' >> /etc/default/grub
    grep -q '^GRUB_TERMINAL=' /etc/default/grub || echo 'GRUB_TERMINAL="console serial"' >> /etc/default/grub
    grep -q '^GRUB_SERIAL_COMMAND=' /etc/default/grub || echo 'GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"' >> /etc/default/grub
    grub2-mkconfig -o /boot/grub2/grub.cfg || exit 1
    grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg || exit 1
}
