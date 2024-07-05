#/bin/bash

[[ -x /tmp/archives/docker/docker.restore.sh ]] && {
	echo "Loading Docker/Podman images"
	/tmp/archives/docker/docker.restore.sh
}
