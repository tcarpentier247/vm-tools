#!/bin/bash

# prevent bash_completion errors after scp
# set -a

QASCRIPTS=~opensvc/opensvc-qa.d

[[ ! -d ${QASCRIPTS} ]] && {
    echo "Error : missing opensvc qa scripts ${QASCRIPTS}. Exiting."
    exit 1
}

cd ${QASCRIPTS}

echo "QA : Loading environment from ${QASCRIPTS} as user `whoami`"

for s in $(ls -1 *.sh 2>/dev/null) ; do
    test -r $s && echo "=> loading $s" && . $s
done

for s in $(ls -1 *.bash 2>/dev/null) ; do
    test -r $s && echo "=> loading $s" && . $s
done

cd ${QASCRIPTS}/..
