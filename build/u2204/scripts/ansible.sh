#!/bin/bash -eu

echo "--- Begin ansible.sh ---"

export DEBIAN_FRONTEND=noninteractive

# Install Ansible repository.
apt -y update && sudo apt-get -y dist-upgrade
apt -y install software-properties-common
apt-add-repository ppa:ansible/ansible

# Install Ansible.
apt -y update
apt -y install ansible

apt clean

echo "--- End ansible.sh ---"
