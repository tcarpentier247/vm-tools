#!/bin/bash

echo "Git cloning vm-tools repository to /opt/vm-tools"

git clone https://github.com/opensvc/vm-tools.git /opt/vm-tools || exit 1
