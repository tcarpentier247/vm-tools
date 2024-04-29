#!/bin/bash -eu

echo "--- Begin ansible.sh ---"

zypper --non-interactive --gpg-auto-import-keys python-pip

pip install ansible==2.9.2

ansible-galaxy collection install ansible.posix --server="https://old-galaxy.ansible.com"

echo "--- End ansible.sh ---"
