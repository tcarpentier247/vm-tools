#!/bin/bash -eu

echo "--- Begin ansible.sh ---"

dnf install -y ansible-core

ansible-galaxy collection install ansible.posix

echo "--- End ansible.sh ---"
