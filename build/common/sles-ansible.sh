#!/bin/bash

echo "Installing Ansible"

zypper --non-interactive --gpg-auto-import-keys install ansible
