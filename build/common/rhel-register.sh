#!/bin/bash

set -a 

RHN_ORG=${RHN_ORG:-undefined}
RHN_KEY=${RHN_KEY:-undefined}

MAJOR_VERSION=$(grep ^VERSION_ID /etc/os-release | awk -F= '{print $2}' | sed -e 's/"//g' | awk -F. '{print $1}')
OS_ID=$(grep ^ID= /etc/os-release | awk -F= '{print $2}' | sed -e 's/"//g')

echo '==> Attaching Red Hat subscriptions'
echo '==> Credentials are' ${RHN_ORG} 'and' ${RHN_KEY}
subscription-manager unregister

subscription-manager register --org ${RHN_ORG} --activationkey ${RHN_KEY}

[[ ${MAJOR_VERSION} -eq 7 ]] && [[ ${OS_ID} == "rhel" ]] && {
    yum clean all
    subscription-manager repos --enable rhel-7-server-optional-rpms
    subscription-manager repos --enable rhel-7-server-extras-rpms
    yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    yum repolist
    echo '==> Subscriptions successfully attached'
    exit 0
}

dnf clean all

subscription-manager repos --enable rhel-${MAJOR_VERSION}-for-x86_64-supplementary-rpms
subscription-manager repos --enable codeready-builder-for-rhel-${MAJOR_VERSION}-x86_64-rpms
dnf repolist

echo '==> Subscriptions successfully attached'
exit 0
