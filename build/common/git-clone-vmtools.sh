#!/bin/bash

[[ -f /etc/profile ]] && . /etc/profile

if [ ! -d /opt/vm-tools ]
then
    echo "Git cloning https://github.com/opensvc/vm-tools.git to /opt/vm-tools"
    git clone https://github.com/opensvc/vm-tools.git /opt/vm-tools || exit 1
else
    echo "Updating /opt/vm-tools git repository"
    cd /opt/vm-tools
    git pull --all || exit 1
fi

