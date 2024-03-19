#!/bin/bash -eu

echo "--- Begin ansible.sh ---"

export DEBIAN_FRONTEND=noninteractive

dnf install -y ansible

echo "--- End ansible.sh ---"
