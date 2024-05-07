#!/bin/bash

echo "Starting Cloud Init"

export DEBIAN_FRONTEND=noninteractive

apt -y install cloud-init

systemctl enable cloud-init.service
systemctl enable cloud-init-local.service
systemctl enable cloud-config.service
systemctl enable cloud-final.service

echo "Cloud Init succesfully enabled"
