#!/bin/bash

[[ -x /opt/archives/docker/docker.restore.sh ]] && {
	echo "Loading Docker/Podman images"
	/opt/archives/docker/docker.restore.sh
}
