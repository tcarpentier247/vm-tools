#!/bin/bash

echo "Installing Ansible"

zypper --non-interactive --gpg-auto-import-keys install ansible

ansible-galaxy collection install ansible.posix
