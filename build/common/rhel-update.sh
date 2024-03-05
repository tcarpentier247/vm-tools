#!/bin/bash

set -a

echo '==> Updating Red Hat packages'

[[ ${MAJOR_VERSION} -eq 7 ]] && [[ ${OS_ID} == "rhel" ]] && {
	yum -y update
	exit 0
}

dnf -y update
echo '==> Packages Successfully updated'
exit 0
