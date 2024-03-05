#!/bin/bash -eu

echo "--- Begin ansible.sh ---"

export DEBIAN_FRONTEND=noninteractive

# Install Ansible repository.
dnf update -y
dnf install -y dnf-utils

# Install Ansible.
dnf update -y
dnf install -y ansible

dnf clean all

echo "--- End ansible.sh ---"
