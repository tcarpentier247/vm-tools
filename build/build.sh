#!/bin/bash

set -a

#CFG_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#ROOT=$(cd -- $CFG_DIR/.. &> /dev/null && pwd )

#PACKER_PLUGIN_PATH=$ROOT/packer/plugins
#PACKER_CACHE_DIR=$ROOT/packer/cache

. packer/environment

DISTRO_IMG=$@

for img in $DISTRO_IMG
do
    [[ ! -d $img ]] && continue
    echo "--- building image $img ---"
    cd $img && {
	rm -rf output-*
        PACKER_LOG=1 packer build -var-file=$img.secrets.pkrvars.hcl  $img.pkr.hcl
        cd -
    }
done

exit 0
