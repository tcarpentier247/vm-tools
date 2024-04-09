#!/bin/bash

echo "Installing Cloud Init"

zypper --non-interactive --gpg-auto-import-keys install cloud-init
systemctl enable cloud-init.service
systemctl enable cloud-init-local.service
systemctl enable cloud-config.service
systemctl enable cloud-final.service
