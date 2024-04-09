#!/bin/bash -eu

echo "--- Begin ansible.sh ---"

export DEBIAN_FRONTEND=noninteractive

apt -y install software-properties-common
apt-add-repository ppa:ansible/ansible

apt -y install ansible

apt clean

echo "--- End ansible.sh ---"
