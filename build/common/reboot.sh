#!/bin/bash

echo "--- Begin reboot.sh ---"

which systemctl > /dev/null 2>&1 && systemctl reboot

echo "--- End reboot.sh ---"
