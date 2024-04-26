#!/bin/sh
#
PATH_SCRIPT="$(cd $(/usr/bin/dirname $(whence -- $0 2>/dev/null|| echo $0));pwd)"

cd $PATH_SCRIPT || exit 1

ANSIBLE=ansible-playbook
ANSIBLE_OPTS='-e callbacks_enabled=profile_tasks'
which ansible-playbook-3 >>/dev/null 2>&1 && ANSIBLE="ansible-playbook-3 -e ansible_python_interpreter=/usr/bin/python2"

$ANSIBLE $ANSIBLE_OPTS ./bootstrap.yml
