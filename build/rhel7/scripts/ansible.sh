#!/bin/bash -eu

echo "--- Begin ansible.sh ---"

yum -y --disablerepo="*" --enablerepo=rhel-7-server-ansible-2-rpms install ansible

ansible-galaxy collection install ansible.posix

echo "--- End ansible.sh ---"
