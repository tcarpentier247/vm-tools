#!/bin/bash

# zypper: Unknown option '--allow-unsigned-rpm'
grep -q '^pkg_gpgcheck = off' /etc/zypp/zypp.conf || echo 'pkg_gpgcheck = off' >> /etc/zypp/zypp.conf

exit 0
