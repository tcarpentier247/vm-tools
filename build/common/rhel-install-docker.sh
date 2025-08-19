#!/bin/bash
#

echo '==> Installing Docker'

sudo dnf -y remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine \
                  podman \
                  runc

sudo dnf -y install dnf-plugins-core

sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

grep -wq el10 /etc/os-release && sudo sed -i 's@linux/rhel@linux/centos@g' /etc/yum.repos.d/docker-ce.repo

sudo dnf makecache

sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable --now docker
