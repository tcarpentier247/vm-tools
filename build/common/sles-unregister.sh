#!/bin/bash

echo "Unregistering SUSE node"

SUSEConnect -d
SUSEConnect --cleanup
