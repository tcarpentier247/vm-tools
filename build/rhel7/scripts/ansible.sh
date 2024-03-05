#!/bin/bash

echo "--- Begin ansible.sh ---"

export DEBIAN_FRONTEND=noninteractive

# Install Ansible.
yum install -y ansible

echo "--- End ansible.sh ---"

exit 0
