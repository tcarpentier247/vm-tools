#!/bin/bash

echo
echo "####################"
echo "######## MD ########"
echo "####################"
echo

[[ -f ~opensvc/opensvc-qa.sh ]] && . ~opensvc/opensvc-qa.sh

which mdadm >> /dev/null 2>&1 || {
	echo "error: mdadm not found"
        exit 1
}

[[ ! -f /etc/mdadm.conf ]] && {
    [[ ! -f /etc/mdadm/mdadm.conf ]] && {
        echo "No mdadm config file found. Creating /etc/mdadm.conf"
        touch /etc/mdadm.conf
    }
}

for file in /etc/mdadm.conf /etc/mdadm/mdadm.conf
do
  test -f $file && {
      echo "File $file is found"
      grep -q '^AUTO -all' $file 2>/dev/null || {
          echo "Populating $file  with AUTO -all"
          echo "AUTO -all" >> $file
      }
  }
done

grep -qw "^md" /etc/modules-load.d/10-load-opensvc-modules.conf 2>/dev/null || {
    echo 'md' >> /etc/modules-load.d/10-load-opensvc-modules.conf
}

exit 0
