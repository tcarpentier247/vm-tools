#!/bin/bash

# disable docker iptables
grep -q 'iptables=false' /etc/sysconfig/docker || echo 'DOCKER_NETWORK_OPTIONS="--iptables=false"' >> /etc/sysconfig/docker

/bin/true
