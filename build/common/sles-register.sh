#!/bin/bash

SUSE_KEY=${SUSE_KEY:-undefined}
SUSE_EMAIL=${SUSE_EMAIL:-undefined}

SUSEConnect -r ${SUSE_KEY} -e ${SUSE_EMAIL} || exit 1

DIST_VERSION=$(grep ^VERSION_ID /etc/os-release | awk -F= '{print $2}' | xargs)
DIST_MAJOR_VERSION=${DIST_VERSION%.*}

[[ $DIST_MAJOR_VERSION == "15" ]] && {
	SUSEConnect -p sle-module-basesystem/$DIST_VERSION/x86_64
	SUSEConnect -p sle-module-containers/$DIST_VERSION/x86_64
	SUSEConnect -p sle-module-desktop-applications/$DIST_VERSION/x86_64
	SUSEConnect -p sle-module-development-tools/$DIST_VERSION/x86_64
	SUSEConnect -p PackageHub/$DIST_VERSION/x86_64
	SUSEConnect -p sle-module-legacy/$DIST_VERSION/x86_64
	SUSEConnect -p sle-module-public-cloud/$DIST_VERSION/x86_64
	SUSEConnect -p sle-module-web-scripting/$DIST_VERSION/x86_64
}

[[ $DIST_MAJOR_VERSION == "12" ]] && {
	SUSEConnect -p sle-module-adv-systems-management/$DIST_MAJOR_VERSION/x86_64
	SUSEConnect -p sle-module-containers/$DIST_MAJOR_VERSION/x86_64
	SUSEConnect -p sle-module-legacy/$DIST_MAJOR_VERSION/x86_64
	SUSEConnect -p sle-module-public-cloud/$DIST_MAJOR_VERSION/x86_64
	SUSEConnect -p PackageHub/$DIST_VERSION/x86_64
	SUSEConnect -p sle-module-toolchain/$DIST_MAJOR_VERSION/x86_64
	SUSEConnect -p sle-module-web-scripting/$DIST_MAJOR_VERSION/x86_64
	SUSEConnect -p sle-sdk/$DIST_VERSION/x86_64
}

echo
echo "Listing SUSE Registrations"

SUSEConnect -l
