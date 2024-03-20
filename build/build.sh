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
    PACKER_OPTS=""
    cd $img && {
	rm -rf output-*
        [[ -f $img.secrets.pkrvars.hcl ]] && PACKER_OPTS="$PACKER_OPTS -var-file=$img.secrets.pkrvars.hcl"
        PACKER_LOG=1 packer build $PACKER_OPTS $img.pkr.hcl
        cd -
    }
done

exit 0
