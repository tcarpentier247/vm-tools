#!/bin/bash

echo "CNI tarball Install"

[[ ! -f /opt/archives/cni/cni.sh ]] && {
    echo "CNI install script not found"
    exit 1
}

cd /opt/archives/cni && ./cni.sh
